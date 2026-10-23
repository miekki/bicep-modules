---
name: bicep-module-authoring
description: "Author and test reusable Azure Bicep registry modules in this repository. Use for module parameters, resource definitions, test/main.test.bicep scenarios, Bicep build and lint, PSRule analysis, or Azure deployment preflight validation."
---

# Azure Bicep Module Authoring

Use this workflow when adding or changing a reusable Azure Bicep registry module. Keep tests focused on module behavior; for assertion design, also follow [bicep-module-testing](../bicep-module-testing/SKILL.md) and [test-discipline](../test-discipline/SKILL.md). Use [bicep-psrule-validation](../bicep-psrule-validation/SKILL.md) and [bicep-module-documentation](../bicep-module-documentation/SKILL.md) for those parts of the workflow.

## Workflow

1. Find the module under `modules/<area>/<name>/`. Read its `main.bicep`, `test/main.test.bicep`, `README.md`, and a nearby module with similar resources before changing the public contract. Keep the implementation in `main.bicep`; reuse shared types in `modules/common-types/main.bicep` when appropriate.
2. Define the public interface with Bicep types, `@description` on parameters and outputs, defaults for optional inputs, and `@allowed` constraints for closed sets. Keep the README parameter names, types, and defaults synchronized with the source.
3. Build behavior in a way that can be checked without Azure where practical. The Key Vault module is a useful pattern for deriving network ACL objects and public-network-access defaults into variables and asserting those transformations. Avoid assertions that evaluate resource `reference()` expressions in the local test runner; they may be skipped because ARM does not allow those expressions in assertion locations.
4. Add or update `test/main.test.bicep` with a minimal-parameters scenario and focused scenarios for meaningful optional behavior. Use relative module paths such as `../main.bicep`; tests should not require real credentials or deployed resources merely to check input-derived configuration.
5. Validate with the focused build, Bicep test, and PSRule workflow below. CI also performs Azure preflight validation with the module-specific parameters. Do not treat a local Bicep test pass as a substitute for PSRule or Azure preflight.

## Focused validation

From the repository root, replace `<area>` and `<name>` with the module path:

```bash
az bicep build --file modules/<area>/<name>/main.bicep
az bicep build --file modules/<area>/<name>/test/main.test.bicep
az bicep run --command "test modules/<area>/<name>/test/main.test.bicep"
PSRULE_AZURE_BICEP_USE_AZURE_CLI=true pwsh -NoLogo -Command 'Invoke-PSRule -InputPath modules/<area>/<name>/test/main.test.bicep'
```

The Bicep `test` subcommand is not exposed as `az bicep test` in this Azure CLI command group; forward it with `az bicep run --command`. The PSRule command requires Azure CLI with Bicep installed and the `PSRule.Rules.Azure` PowerShell module. CI runs PSRule against the test template, then performs deployment preflight against the module itself. To run preflight locally, use a signed-in Azure CLI context and the module's test resource group and parameters, following `.github/workflows/template-module.yml`:

```bash
az deployment group validate \
  --resource-group "<test-resource-group>" \
  --template-file "modules/<area>/<name>/main.bicep" \
  --parameters @modules/<area>/<name>/test/<parameters-file>.json
```

Use Bicep build for syntax and compile-time checks; Bicep tests for input-derived assertions; PSRule for Azure configuration guidance; and preflight for Azure validation without deployment. If credentials or a test resource group are unavailable, report preflight as not run rather than treating another check as equivalent.

## Repository examples

- `modules/network/virtual-network/main.bicep` and `test/main.test.bicep` show a module with subnet transformation and management-lock assertions.
- `modules/security/keyvault/main.bicep` and `test/main.test.bicep` show secure defaults, normalized network ACLs, public-network-access selection, and a focused custom-configuration scenario.
- Their READMEs demonstrate parameter defaults and custom-type property tables; keep those docs aligned with the source rather than copying old or inaccurate snippets.
