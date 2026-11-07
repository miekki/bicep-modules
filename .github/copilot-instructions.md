# Copilot instructions

## Project structure

- This repository publishes reusable Azure Bicep modules from `modules/<domain>/<module>/`.
- A public module normally has `main.bicep`, `test/main.test.bicep`, and a `README.md`. Keep its required/full-parameter examples in `examples/` when present.
- Shared types live in `modules/common-types/`; network implementation helpers live under `modules/network/internal-modules/`. Reuse these patterns instead of duplicating shared definitions.
- Keep each module's README parameter, output, and example documentation aligned with its public Bicep interface.

## Bicep conventions

- Follow neighboring modules: declare module metadata, document parameters and outputs with `@description`, make required/optional status and defaults clear, and use shared types from `modules/common-types/` where appropriate.
- Preserve the module's public parameter and output contract unless a breaking change is intended. Prefer typed parameters and safe defaults over loosely shaped inputs.
- When creating or updating a resource module, check whether its managed resource supports Azure management locks and RBAC role assignments. Where applicable, expose optional `lock` and `roleAssignments` parameters using shared types from `modules/common-types/`, follow neighboring modules' resource-scoped implementation patterns, and cover the options in tests, full-parameter examples, and README documentation.
- Follow `bicepconfig.json` analyzers and `ps-rule.yaml`; use current Azure resource API versions and avoid hardcoded environment-specific values.
- Add or update `test/main.test.bicep` to exercise required parameters and meaningful optional configurations. Keep examples and documentation consistent with those scenarios.
- In deployable examples, build resource and resource-group names with `var` declarations. Follow neighboring examples by loading `modules/abbreviations.json` with the correct relative path and using the matching abbreviation for resource types that have one.
- In module READMEs, follow the Key Vault README's parameter documentation pattern: link parameter names to their detail sections, keep type cells plain text, and document custom types and nested fields. In custom-type detail tables, link a field name when it has its own detail section; keep type names plain text. Verify internal links resolve.
- When a module has deployable examples, include `examples/sample-deployments.azcli` with Azure CLI commands for its required- and full-parameter examples, and link it from the README. Match the deployment command to each example's `targetScope`. Follow the Key Vault sample convention and use `az stack <scope> create` for subscription- or resource-group-scoped examples; quote shell variables. Set `--action-on-unmanage detachAll` so unmanaging a stack does not delete example resources. Do not use `deleteAll` or add destructive cleanup commands to reusable samples.

## Validation

- Build a changed module with `az bicep build --file modules/<domain>/<module>/main.bicep`. Build its test template too when it changes.
- For module-level Azure policy checks, follow the local PSRule setup and command documented in the root `README.md`. CI also runs PSRule against the module test template and an Azure deployment preflight.
- Do not claim Azure preflight or deployment validation was run unless it was actually performed with the required Azure access.

## Releases

- Modules are versioned and published independently. Use Conventional Commit subjects scoped to the module, such as `fix(storage-account): ...` or `feat(keyvault): ...`; use `!` or a `BREAKING CHANGE:` footer for breaking changes.
- Check the module's workflow and the root README before changing release behavior. Do not manually increment a module version without following that module's release/tagging process.
