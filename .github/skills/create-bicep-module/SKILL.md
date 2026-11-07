---
name: create-bicep-module
description: "Use when adding a reusable Azure Bicep module to this registry, including its tests, examples, documentation, and release workflow."
disable-model-invocation: true
argument-hint: "Describe the Azure resource, desired behavior, and any required security or deployment constraints"
---
Create a complete, reusable Azure Bicep module for this repository from the requirements supplied with this prompt.

## Before implementation

1. Read [the project Copilot instructions](../../copilot-instructions.md) and inspect the closest existing public module, its test, examples, README, metadata, changelog, and GitHub workflow.
2. Use [the Key Vault module](../../../modules/security/keyvault/main.bicep) and [the Key Vault secrets module](../../../modules/security/keyvault-secrets/main.bicep) as security-domain references, not as defaults for unrelated resources:
   - The Key Vault module owns a vault and composes secret and private-endpoint modules.
   - The secrets module targets an existing vault; its secret value is secure and must not be exposed in outputs.
3. Check `modules/common-types/`, `bicepconfig.json`, `ps-rule.yaml`, and the shared module workflow before introducing types or validation patterns.
4. Verify the resource type, deployment scope, API version, and property names against available Bicep schema tools or current official Azure resource documentation. Do not guess API versions or copy an obsolete version without checking.
5. If the requirements leave a consequential choice unresolved—such as resource ownership, deployment scope, authorization model, network exposure, secret handling, or destructive behavior—ask focused questions before implementing. Do not silently choose a less-secure or behavior-changing default.

## Implement the module

Create the module under `modules/<domain>/<module-name>/` using the repository's lower-kebab-case naming. Follow the closest module's conventions and create the applicable files:

- `main.bicep`: declare useful module metadata; document parameters and outputs; use precise types, validation decorators, and secure parameters where appropriate; reuse shared types when they fit. Keep the public interface focused and avoid unrelated resources or speculative options.
- `test/main.test.bicep`: exercise the minimum configuration and meaningful optional/security configurations using the repository's deployment-test patterns.
- `examples/required-parameters/main.bicep` and `examples/full-parameters/main.bicep`: provide valid, self-contained usage examples. Build resource and resource-group names with `var` declarations. Load `modules/abbreviations.json` using the correct relative path and use its abbreviation for resource types that have one, following neighboring examples. Include a deployment sample only when the module needs a larger composition to explain its use.
- `examples/sample-deployments.azcli`: include Azure CLI commands to deploy the required- and full-parameter examples using `az stack <scope> create`, following the Key Vault sample. Match the stack scope to each example's `targetScope` (for example, `az stack sub create` for subscription templates). Quote shell variables and set `--action-on-unmanage detachAll` so unmanaging the stack does not delete example resources. Do not use `deleteAll` or add destructive cleanup commands to reusable samples.
- `README.md`: document behavior, prerequisites, every parameter (type, required status, default, description), outputs, and working examples. Keep it synchronized with `main.bicep` and follow [the Key Vault README](../../../modules/security/keyvault/README.md) for the parameter table layout. Link to `examples/sample-deployments.azcli` in the Examples section.
  - Link parameter names to their detail sections. Keep the type column plain text (for example, link `networkAcls`, not `networkAclsType`).
  - Document each custom parameter type and its nested fields in detail tables. Use `### Parameter: \`<name>\`` headings for detail sections, including custom types, to follow the repository's existing README convention.
  - In custom-type tables, link a field name to its detail section when that field has one; keep type names unlinked. Use the same name-only link convention for nested configuration fields.
  - Check all internal README links resolve and avoid linking the name and type together.
- `metadata.json`: follow the registry release baseline schema and conventions; choose an initial baseline only when supported by the repository's release rules.
- `CHANGELOG.md`: start an Unreleased section describing the initial module addition.

For secrets or other sensitive values, use `@secure()` as appropriate, never output or log the value, and use clearly fake sample values only where a deployable example requires one. Do not copy real principal IDs, credentials, tenant IDs, resource IDs, or other environment-specific values from an existing module.

## Register and validate

- Add `.github/workflows/module-<module-name>.yml`, following a comparable module workflow and the shared template in `.github/workflows/template-module.yml`. Set its path filter, module name/path, metadata path, and valid preflight parameters; never put real secrets in workflow inputs. Confirm the module's `targetScope` is supported by the shared template's deployment-group preflight. If it is not, explain the mismatch and ask before changing shared release infrastructure.
- Add the new workflow name to the explicit workflow list in `.github/workflows/publish-docs.yml`. The module catalog scans public module directories automatically; do not hand-edit generated catalog output.
- Build the module, test template, and examples with `az bicep build`. Run applicable repository checks, including PSRule using the documented local setup when available. Do not claim Azure preflight or deployment validation unless it was actually run with authorized Azure access.
- Do not publish, deploy, or commit changes. Summarize created files, validation results, and any remaining assumptions or Azure-only checks.
