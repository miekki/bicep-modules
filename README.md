# Bicep registry

This repo contains the source code for all the common used bicep modules to build modern cloud application on Azure.

## Available modules

List with available modules can be found on our [documentation page](https://miekki.github.io/bicep-modules/)

## Module releases

Each registry module is released independently with a stable SemVer tag. Commits that change a
module must use [Conventional Commits](https://www.conventionalcommits.org/), for example:

- `feat(keyvault): add rotation support` selects a minor release.
- `fix(storage-account): correct the default tier` or another non-breaking change selects a patch.
- `feat(keyvault)!: rename an output` or a `BREAKING CHANGE:` footer selects a major release.

The shared module workflow checks only non-merge commits that affect that module's directory. If one
commit changes multiple modules, each module evaluates that commit against its own release history
and version baseline. Missing or invalid Conventional Commit subjects fail the release rather than
silently guessing; merge commits are ignored when their constituent commits are present. A manual
run with no module-specific changes does not publish.

After a successful ACR publish, the workflow creates the corresponding module-namespaced Git tag,
such as `modules/keyvault/v1.2.3`. That tag is the canonical boundary for subsequent module-specific
release notes and version calculations. The same selected numeric SemVer (without the `v`) is
published to ACR. Documentation continues to obtain each published version from ACR.

For the first release before a module has a namespaced tag, the workflow uses the push event's
previous commit as the history boundary and chooses the next version above the highest stable version
found in that module's existing ACR tags and `metadata.json` baseline. The metadata `version` field
is only a one-time bootstrap floor; it is not incremented or used after a namespaced module release
tag exists. This preserves existing ACR tags and does not require republishing them. A manual run
before the first module tag is deliberately rejected because it has no safe push-history boundary.
The repository Actions token must be allowed to write contents/tags, and repository tag rules must
allow the workflow to create `modules/*/v*` tags.
Each release's commit list is written to the GitHub Actions summary as the release notes, using the
same module-specific commit range that selected the version.
