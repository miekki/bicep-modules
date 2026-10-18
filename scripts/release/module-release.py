#!/usr/bin/env python3
"""Select and document the next stable release for one Bicep module."""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path


VERSION_PATTERN = re.compile(r"^(?:v)?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:\.(0|[1-9][0-9]*))?$")
COMMIT_PATTERN = re.compile(
    r"^(?P<type>[a-z][a-z0-9-]*)(?:\((?P<scope>[^()\r\n]+)\))?(?P<breaking>!)?: (?P<description>\S.*)$"
)
BREAKING_FOOTER_PATTERN = re.compile(r"(?m)^BREAKING CHANGE:\s*\S")


class ReleaseError(Exception):
    """An unsafe or invalid release request."""


def run_git(root, *args, check=True):
    result = subprocess.run(
        ["git", *args],
        cwd=root,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if check and result.returncode:
        raise ReleaseError(result.stderr.strip() or "Git command failed.")
    return result


def parse_version(value, allow_short=False, allow_v_prefix=False):
    value = str(value)
    if value.startswith("v") and not allow_v_prefix:
        return None
    match = VERSION_PATTERN.fullmatch(value)
    if not match:
        return None
    if match.group(3) is None and not allow_short:
        return None
    return (int(match.group(1)), int(match.group(2)), int(match.group(3) or 0))


def format_version(version):
    return ".".join(str(part) for part in version)


def assert_registry_version_available(version, registry_tags):
    for tag in registry_tags:
        if parse_version(tag, allow_v_prefix=True) == version:
            raise ReleaseError(
                "Selected version {} already exists in the registry as tag {!r}; "
                "refusing to overwrite it.".format(format_version(version), tag)
            )


def read_registry_tags():
    raw_tags = os.environ.get("REGISTRY_TAGS_JSON", "[]")
    try:
        tags = json.loads(raw_tags)
    except json.JSONDecodeError as error:
        raise ReleaseError("REGISTRY_TAGS_JSON must contain a JSON array of tag strings.") from error
    if not isinstance(tags, list) or any(not isinstance(tag, str) for tag in tags):
        raise ReleaseError("Registry tags must be a JSON array of strings.")
    return tags


def latest_module_tag(root, module_name):
    namespace = "modules/{}/v".format(module_name)
    raw_tags = run_git(root, "tag", "--list", "{}*".format(namespace)).stdout
    eligible = []

    for tag in raw_tags.splitlines():
        version_text = tag[len(namespace) :]
        version = parse_version(version_text)
        if version is None:
            raise ReleaseError(
                "Invalid module release tag {!r}; expected {}MAJOR.MINOR.PATCH.".format(
                    tag, namespace
                )
            )
        ancestor = run_git(root, "merge-base", "--is-ancestor", tag, "HEAD", check=False)
        if ancestor.returncode == 0:
            eligible.append((version, tag))
        elif ancestor.returncode != 1:
            raise ReleaseError(ancestor.stderr.strip() or "Unable to inspect release tag ancestry.")

    if not eligible:
        return None
    return max(eligible, key=lambda item: item[0])


def collect_commits(root, module_path, revision):
    record_format = "%H%x1f%P%x1f%s%x1f%b%x1e"
    commits_output = run_git(
        root,
        "log",
        "--no-merges",
        "--reverse",
        "--format={}".format(record_format),
        revision,
        "--",
        module_path,
    ).stdout
    commits = []

    for record in commits_output.split("\x1e"):
        if not record.strip():
            continue
        fields = record.split("\x1f", 3)
        if len(fields) != 4:
            raise ReleaseError("Unable to parse Git history for module {}.".format(module_path))
        commit_hash, parents, subject, body = fields
        if len(parents.split()) > 1:
            continue

        match = COMMIT_PATTERN.fullmatch(subject)
        if not match:
            raise ReleaseError(
                "Commit {} affecting {} has a missing or invalid Conventional Commit "
                "subject: {!r}".format(commit_hash[:12], module_path, subject)
            )

        breaking = bool(match.group("breaking")) or bool(
            BREAKING_FOOTER_PATTERN.search(body)
        )
        change_type = match.group("type")
        bump = "major" if breaking else "minor" if change_type == "feat" else "patch"
        commits.append(
            {
                "hash": commit_hash,
                "subject": subject,
                "body": body.strip(),
                "bump": bump,
            }
        )

    merge_hashes = run_git(root, "rev-list", "--merges", revision).stdout.splitlines()
    module_merges = []
    for merge_hash in merge_hashes:
        changed_paths = run_git(
            root,
            "diff-tree",
            "--no-commit-id",
            "--name-only",
            "-r",
            "-m",
            merge_hash,
        ).stdout.splitlines()
        if any(path == module_path or path.startswith(module_path + "/") for path in changed_paths):
            module_merges.append(merge_hash)

    if module_merges and not commits:
        raise ReleaseError(
            "Module changes in {} are represented only by merge commits. "
            "Use Conventional Commit changesets in the merged history.".format(module_path)
        )
    return commits, len(module_merges)


def next_version(baseline, commits):
    if any(commit["bump"] == "major" for commit in commits):
        return (baseline[0] + 1, 0, 0)
    if any(commit["bump"] == "minor" for commit in commits):
        return (baseline[0], baseline[1] + 1, 0)
    return (baseline[0], baseline[1], baseline[2] + 1)


def release_plan(
    root, module_name, module_path, baseline_file, registry_tags, bootstrap_base_ref=None
):
    root = Path(root).resolve()
    module_path = Path(module_path).as_posix().strip("/")
    if not module_name or "/" in module_name or module_name in (".", ".."):
        raise ReleaseError("Module name must be a non-empty registry repository name.")
    if (
        not module_path
        or module_path.startswith("../")
        or Path(module_path).is_absolute()
        or ".." in Path(module_path).parts
    ):
        raise ReleaseError("Module path must be a repository-relative path.")

    previous = latest_module_tag(root, module_name)
    if previous:
        revision = "{}..HEAD".format(previous[1])
    else:
        if not bootstrap_base_ref or re.fullmatch(r"0+", bootstrap_base_ref):
            raise ReleaseError(
                "No module release tag exists yet. A push base commit is required for the "
                "first release so legacy history is not treated as a new release."
            )
        if not re.fullmatch(r"[0-9a-fA-F]{40,64}", bootstrap_base_ref):
            raise ReleaseError("Bootstrap base must be a full Git commit SHA.")
        base_commit = run_git(root, "rev-parse", "--verify", bootstrap_base_ref).stdout.strip()
        ancestor = run_git(
            root, "merge-base", "--is-ancestor", base_commit, "HEAD", check=False
        )
        if ancestor.returncode != 0:
            raise ReleaseError("Bootstrap base commit must be an ancestor of HEAD.")
        revision = "{}..HEAD".format(base_commit)
    commits, merge_count = collect_commits(root, module_path, revision)
    if previous:
        baseline = previous[0]
    else:
        baseline_path = root / baseline_file
        try:
            metadata_version = json.loads(baseline_path.read_text())["version"]
        except (OSError, json.JSONDecodeError, KeyError, TypeError) as error:
            raise ReleaseError(
                "Unable to read the initial version baseline from {}.".format(baseline_file)
            ) from error
        baseline = parse_version(metadata_version, allow_short=True)
        if baseline is None:
            raise ReleaseError(
                "Initial version baseline in {} must be MAJOR.MINOR or MAJOR.MINOR.PATCH.".format(
                    baseline_file
                )
            )

    valid_registry_versions = [
        version
        for tag in registry_tags
        if (version := parse_version(tag, allow_v_prefix=True)) is not None
    ]
    if valid_registry_versions:
        baseline = max([baseline, *valid_registry_versions])

    if not commits:
        return {
            "should_release": False,
            "version": "",
            "baseline": baseline,
            "previous_tag": previous[1] if previous else "",
            "range": revision,
            "commits": [],
            "merge_count": merge_count,
        }

    version = next_version(baseline, commits)
    selected_version = format_version(version)
    assert_registry_version_available(version, registry_tags)
    tag = "modules/{}/v{}".format(module_name, selected_version)
    tag_exists = run_git(
        root, "show-ref", "--verify", "--quiet", "refs/tags/{}".format(tag), check=False
    )
    if tag_exists.returncode == 0:
        raise ReleaseError(
            "Module release tag {} already exists; refusing to overwrite it.".format(tag)
        )
    if tag_exists.returncode != 1:
        raise ReleaseError(tag_exists.stderr.strip() or "Unable to inspect module release tags.")

    return {
        "should_release": True,
        "version": selected_version,
        "baseline": baseline,
        "previous_tag": previous[1] if previous else "",
        "range": revision,
        "commits": commits,
        "merge_count": merge_count,
    }


def append_github_output(path, plan):
    if not path:
        return
    with open(path, "a", encoding="utf-8") as output:
        output.write("should_release={}\n".format(str(plan["should_release"]).lower()))
        output.write("version={}\n".format(plan["version"]))


def append_summary(path, module_name, module_path, plan):
    if not path:
        return
    with open(path, "a", encoding="utf-8") as summary:
        summary.write("## Module release: `{}`\n\n".format(module_name))
        summary.write("- Module path: `{}`\n".format(module_path))
        summary.write("- Commit range: `{}` (module-specific paths)\n".format(plan["range"]))
        summary.write("- Baseline: `{}`\n".format(format_version(plan["baseline"])))
        if plan["merge_count"]:
            summary.write(
                "- Ignored {} merge commit(s); their non-merge module commits were analyzed.\n".format(
                    plan["merge_count"]
                )
            )
        if not plan["should_release"]:
            summary.write("- Result: no releasable module changes; publishing skipped.\n")
            return
        summary.write("- Selected stable SemVer: `{}`\n\n".format(plan["version"]))
        summary.write("### Release notes\n\n")
        for commit in plan["commits"]:
            summary.write(
                "- `{}` {} ({})\n".format(
                    commit["hash"][:12], commit["subject"], commit["bump"]
                )
            )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--module-name")
    parser.add_argument("--module-path")
    parser.add_argument("--baseline-file")
    parser.add_argument("--base-ref")
    parser.add_argument("--check-version")
    args = parser.parse_args()

    try:
        registry_tags = read_registry_tags()
        if args.check_version:
            expected = parse_version(args.check_version)
            if expected is None:
                raise ReleaseError("--check-version must be a stable MAJOR.MINOR.PATCH version.")
            assert_registry_version_available(expected, registry_tags)
            print("Registry tag {} is available.".format(args.check_version))
            return 0

        if not args.module_name or not args.module_path or not args.baseline_file:
            raise ReleaseError(
                "--module-name, --module-path, and --baseline-file are required."
            )
        plan = release_plan(
            Path.cwd(),
            args.module_name,
            args.module_path,
            args.baseline_file,
            registry_tags,
            args.base_ref or os.environ.get("RELEASE_BASE_SHA"),
        )
        append_github_output(os.environ.get("GITHUB_OUTPUT"), plan)
        append_summary(
            os.environ.get("GITHUB_STEP_SUMMARY"),
            args.module_name,
            args.module_path,
            plan,
        )
        print(
            "should_release={} version={} baseline={} previous_tag={}".format(
                str(plan["should_release"]).lower(),
                plan["version"] or "none",
                format_version(plan["baseline"]),
                plan["previous_tag"] or "none",
            )
        )
        return 0
    except ReleaseError as error:
        print("Release safety check failed: {}".format(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
