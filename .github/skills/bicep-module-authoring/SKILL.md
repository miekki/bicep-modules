---
name: bicep-module-authoring
description: "Author and test reusable Azure Bicep registry modules in this repository. Use for module parameters, resource definitions, test/main.test.bicep scenarios, Bicep build and lint, PSRule analysis, or Azure deployment preflight validation."
---

# Azure Bicep Module Authoring

Use this workflow when adding or changing a reusable Azure Bicep registry module. Keep tests focused on module behavior. For assertions, follow [bicep-module-testing](../bicep-module-testing/SKILL.md) and [test-discipline](../test-discipline/SKILL.md); use [bicep-psrule-validation](../bicep-psrule-validation/SKILL.md) and [bicep-module-documentation](../bicep-module-documentation/SKILL.md) for those workflow steps.

## Workflow

1. Locate `modules/<area>/<name>/`. Before changing its public contract, read `main.bicep`, `test/main.test.bicep`, `README.md`, and a nearby module with similar resources. Implement in `main.bicep`; reuse `modules/common-types/main.bicep` types when appropriate.
2. Define the interface with Bicep types, `@description` on parameters and outputs, defaults for optional inputs, and `@allowed` for closed sets. Keep README parameter names, types, and defaults synchronized with the source.
3. Prefer behavior testable without Azure. The Key Vault module shows deriving network ACL objects and public-network-access defaults into variables, then asserting them. Avoid assertions that evaluate resource `reference()` expressions: the local runner may skip them because ARM disallows them in assertion locations.
4. Add/update `test/main.test.bicep` with a minimal-parameters scenario and focused scenarios for meaningful optional behavior. Use relative paths such as `../main.bicep`; input-derived configuration tests need neither credentials nor deployed resources.
5. Run the focused build, Bicep test, and PSRule checks below. CI also runs Azure preflight with module-specific parameters. A local Bicep test pass does not replace PSRule or Azure preflight.

## Focused validation

From the repository root, replace `<area>` and `<name>` with the module path:

```bash
az bicep build --file modules/<area>/<name>/main.bicep
az bicep build --file modules/<area>/<name>/test/main.test.bicep
az bicep run --command "test modules/<area>/<name>/test/main.test.bicep"
PSRULE_AZURE_BICEP_USE_AZURE_CLI=true pwsh -NoLogo -Command 'Invoke-PSRule -InputPath modules/<area>/<name>/test/main.test.bicep'
```

This Azure CLI command group does not expose `az bicep test`; forward the Bicep `test` subcommand with `az bicep run --command`. PSRule requires Azure CLI with Bicep installed and the `PSRule.Rules.Azure` PowerShell module. CI runs PSRule on the test template, then preflight on the module. For local preflight, use a signed-in Azure CLI context plus the module's test resource group and parameters, following `.github/workflows/template-module.yml`:

```bash
az deployment group validate \
  --resource-group "<test-resource-group>" \
  --template-file "modules/<area>/<name>/main.bicep" \
  --parameters @modules/<area>/<name>/test/<parameters-file>.json
```

Use build for syntax/compile-time checks, Bicep tests for input-derived assertions, PSRule for Azure configuration guidance, and preflight for Azure validation without deployment. If credentials or a test resource group are unavailable, report preflight as not run; no other check is equivalent.

## Repository examples

- `modules/network/virtual-network/main.bicep` and `test/main.test.bicep`: subnet transformation and management-lock assertions.
- `modules/security/keyvault/main.bicep` and `test/main.test.bicep`: secure defaults, normalized network ACLs, public-network-access selection, and a focused custom-configuration scenario.
- Their READMEs show parameter defaults and custom-type property tables; keep docs aligned with source instead of copying outdated or inaccurate snippets.
