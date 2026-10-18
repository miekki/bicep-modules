import importlib.util
import json
import os
import shutil
import subprocess
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[3]
SCRIPT_PATH = REPO_ROOT / "scripts" / "release" / "module-release.py"
SPEC = importlib.util.spec_from_file_location("module_release", SCRIPT_PATH)
module_release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(module_release)


class ModuleReleaseTests(unittest.TestCase):
    def setUp(self):
        self.root = REPO_ROOT / "test" / ".module-release-fixture"
        shutil.rmtree(self.root, ignore_errors=True)
        self.root.mkdir(parents=True)
        self.git("init", "-q")
        self.git("config", "user.email", "release-test@example.invalid")
        self.git("config", "user.name", "Release Test")
        self.git("branch", "-M", "main")

    def tearDown(self):
        shutil.rmtree(self.root, ignore_errors=True)

    def git(self, *args):
        return subprocess.run(
            ["git", *args],
            cwd=self.root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        ).stdout.strip()

    def write(self, relative_path, content):
        file_path = self.root / relative_path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content, encoding="utf-8")

    def commit(self, subject, files):
        for relative_path, content in files.items():
            self.write(relative_path, content)
        self.git("add", ".")
        self.git("commit", "-q", "-m", subject)
        return self.git("rev-parse", "HEAD")

    def metadata(self, module_path, version):
        self.write(
            "{}/metadata.json".format(module_path),
            json.dumps({"version": version}),
        )

    def plan(self, module_name, module_path, registry_tags=None, base_ref=None):
        return module_release.release_plan(
            self.root,
            module_name,
            module_path,
            "{}/metadata.json".format(module_path),
            registry_tags or [],
            base_ref,
        )

    def test_initial_release_uses_highest_existing_registry_version_and_module_changes(self):
        module_path = "modules/security/keyvault"
        self.metadata(module_path, "1.0")
        self.commit(
            "Legacy keyvault update",
            {"{}/main.bicep".format(module_path): "legacy\n"},
        )
        base_ref = self.commit(
            "chore: mark release baseline",
            {"release-baseline.txt": "bootstrap boundary\n"},
        )
        self.commit(
            "feat(keyvault): add secret rotation",
            {"{}/main.bicep".format(module_path): "resource secret {}\n"},
        )
        self.commit("fix: update unrelated module", {"modules/network/main.bicep": "vnet\n"})

        plan = self.plan(
            "keyvault",
            module_path,
            registry_tags=["1.3.4", "legacy", "1.2.8"],
            base_ref=base_ref,
        )

        self.assertTrue(plan["should_release"])
        self.assertEqual(plan["version"], "1.4.0")
        self.assertEqual(plan["range"], "{}..HEAD".format(base_ref))
        self.assertEqual([commit["subject"] for commit in plan["commits"]], [
            "feat(keyvault): add secret rotation"
        ])

    def test_breaking_change_footer_is_major_and_notes_share_tag_range(self):
        module_path = "modules/security/keyvault"
        self.metadata(module_path, "0.1")
        self.commit("chore: initialize module", {module_path + "/main.bicep": "seed\n"})
        self.git("tag", "modules/keyvault/v1.2.3")
        self.commit("feat: unrelated module", {"modules/network/main.bicep": "vnet\n"})
        self.commit(
            "fix(keyvault): change output contract\n\nBREAKING CHANGE: the output has a new shape",
            {
                module_path + "/main.bicep": "changed\n",
                "modules/network/main.bicep": "changed too\n",
            },
        )
        latest = self.git("rev-parse", "HEAD")

        plan = self.plan("keyvault", module_path, registry_tags=["1.2.3"])

        self.assertEqual(plan["version"], "2.0.0")
        self.assertEqual(plan["previous_tag"], "modules/keyvault/v1.2.3")
        self.assertEqual(plan["range"], "modules/keyvault/v1.2.3..HEAD")
        self.assertEqual(len(plan["commits"]), 1)
        self.assertEqual(plan["commits"][0]["hash"], latest)
        self.assertEqual(plan["commits"][0]["bump"], "major")

    def test_header_breaking_marker_selects_major(self):
        module_path = "modules/config/app-configuration"
        self.metadata(module_path, "2.4")
        base_ref = self.commit(
            "chore: establish initial baseline",
            {module_path + "/main.bicep": "seed\n"},
        )
        self.commit(
            "feat(config)!: replace endpoint",
            {module_path + "/main.bicep": "resource app {}\n"},
        )

        self.assertEqual(
            self.plan("app-configuration", module_path, base_ref=base_ref)["version"],
            "3.0.0",
        )

    def test_nonbreaking_commit_selects_patch(self):
        module_path = "modules/storage/storage-account"
        self.metadata(module_path, "1.2")
        base_ref = self.commit(
            "chore: establish initial baseline",
            {module_path + "/main.bicep": "seed\n"},
        )
        self.commit(
            "perf(storage-account): reduce deployment operations",
            {module_path + "/main.bicep": "optimized\n"},
        )

        self.assertEqual(
            self.plan("storage-account", module_path, base_ref=base_ref)["version"],
            "1.2.1",
        )

    def test_invalid_commit_message_blocks_release(self):
        module_path = "modules/database/sqlserver"
        self.metadata(module_path, "0.1")
        base_ref = self.commit(
            "chore: establish initial baseline",
            {module_path + "/main.bicep": "seed\n"},
        )
        self.commit("update SQL settings", {module_path + "/main.bicep": "resource sql {}\n"})

        with self.assertRaisesRegex(module_release.ReleaseError, "Conventional Commit"):
            self.plan("sqlserver", module_path, base_ref=base_ref)

    def test_merge_commit_is_ignored_and_constituent_commits_are_counted(self):
        module_path = "modules/security/keyvault"
        self.metadata(module_path, "1.0")
        base_ref = self.commit("chore: seed", {module_path + "/main.bicep": "seed\n"})
        self.git("checkout", "-q", "-b", "feature")
        self.commit("feat(keyvault): add setting", {module_path + "/main.bicep": "feature\n"})
        self.git("checkout", "-q", "main")
        self.commit("chore: update root readme", {"README.md": "updated\n"})
        subprocess.run(
            ["git", "merge", "--no-ff", "feature", "-m", "Merge feature branch", "-q"],
            cwd=self.root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        plan = self.plan("keyvault", module_path, base_ref=base_ref)

        self.assertEqual(plan["version"], "1.1.0")
        self.assertEqual(plan["merge_count"], 1)
        self.assertEqual(
            [commit["subject"] for commit in plan["commits"]],
            ["feat(keyvault): add setting"],
        )

    def test_commit_affecting_multiple_modules_gets_independent_versions(self):
        alpha = "modules/security/alpha"
        beta = "modules/storage/beta"
        self.metadata(alpha, "1.0")
        self.metadata(beta, "2.3")
        base_ref = self.commit(
            "chore: seed modules",
            {
                alpha + "/main.bicep": "alpha seed\n",
                beta + "/main.bicep": "beta seed\n",
            },
        )
        self.commit(
            "feat(platform): add shared setting",
            {
                alpha + "/main.bicep": "alpha changed\n",
                beta + "/main.bicep": "beta changed\n",
            },
        )

        alpha_plan = self.plan("alpha", alpha, base_ref=base_ref)
        beta_plan = self.plan("beta", beta, base_ref=base_ref)

        self.assertEqual(alpha_plan["version"], "1.1.0")
        self.assertEqual(beta_plan["version"], "2.4.0")
        self.assertEqual(alpha_plan["commits"][0]["hash"], beta_plan["commits"][0]["hash"])

    def test_no_module_commits_skips_release(self):
        module_path = "modules/web/appservice"
        self.metadata(module_path, "1.0")
        self.commit("chore: initialize appservice", {module_path + "/main.bicep": "seed\n"})
        self.git("tag", "modules/appservice/v1.0.0")
        self.commit("docs: update root docs", {"README.md": "docs\n"})

        plan = self.plan("appservice", module_path)

        self.assertFalse(plan["should_release"])
        self.assertEqual(plan["version"], "")
        self.assertEqual(plan["commits"], [])

    def test_first_release_requires_push_base_to_exclude_legacy_history(self):
        module_path = "modules/web/appservice"
        self.metadata(module_path, "1.0")
        self.commit("Old appservice update", {module_path + "/main.bicep": "legacy\n"})

        with self.assertRaisesRegex(module_release.ReleaseError, "push base commit is required"):
            self.plan("appservice", module_path)

    def test_registry_tag_check_refuses_existing_semver(self):
        with self.assertRaisesRegex(module_release.ReleaseError, "already exists"):
            module_release.assert_registry_version_available((1, 2, 3), ["v1.2.3"])

    def test_existing_nonancestor_module_tag_is_never_overwritten(self):
        module_path = "modules/security/keyvault"
        self.metadata(module_path, "1.0")
        base_ref = self.commit(
            "chore: establish initial baseline",
            {module_path + "/main.bicep": "seed\n"},
        )
        self.git("checkout", "-q", "-b", "other-release")
        self.commit(
            "feat(keyvault): release from other branch",
            {module_path + "/main.bicep": "other branch\n"},
        )
        self.git("tag", "modules/keyvault/v1.1.0")
        self.git("checkout", "-q", "main")
        self.commit(
            "feat(keyvault): release from main",
            {module_path + "/main.bicep": "main\n"},
        )

        with self.assertRaisesRegex(module_release.ReleaseError, "Module release tag"):
            self.plan("keyvault", module_path, base_ref=base_ref)

    def test_cli_outputs_release_version_and_notes_from_the_same_range(self):
        module_path = "modules/security/keyvault"
        self.metadata(module_path, "0.1")
        base_ref = self.commit(
            "chore: establish initial baseline",
            {module_path + "/main.bicep": "seed\n"},
        )
        self.commit(
            "feat(keyvault): add rotation",
            {module_path + "/main.bicep": "rotation\n"},
        )
        output_path = self.root / "action-output.txt"
        summary_path = self.root / "action-summary.md"
        environment = dict(os.environ)
        environment.update(
            {
                "REGISTRY_TAGS_JSON": "[]",
                "RELEASE_BASE_SHA": base_ref,
                "GITHUB_OUTPUT": str(output_path),
                "GITHUB_STEP_SUMMARY": str(summary_path),
            }
        )
        result = subprocess.run(
            [
                "python3",
                str(SCRIPT_PATH),
                "--module-name",
                "keyvault",
                "--module-path",
                module_path,
                "--baseline-file",
                module_path + "/metadata.json",
                "--base-ref",
                base_ref,
            ],
            cwd=self.root,
            env=environment,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(output_path.read_text(), "should_release=true\nversion=0.2.0\n")
        summary = summary_path.read_text()
        self.assertIn("Commit range: `{}..HEAD`".format(base_ref), summary)
        self.assertIn("feat(keyvault): add rotation", summary)

        environment["REGISTRY_TAGS_JSON"] = '["v0.2.0"]'
        check_result = subprocess.run(
            ["python3", str(SCRIPT_PATH), "--check-version", "0.2.0"],
            cwd=self.root,
            env=environment,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        self.assertNotEqual(check_result.returncode, 0)
        self.assertIn("already exists", check_result.stderr)


if __name__ == "__main__":
    unittest.main()
