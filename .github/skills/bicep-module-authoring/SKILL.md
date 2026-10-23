---
name: bicep-module-authoring
description: "Author and test reusable Azure Bicep registry modules in this repository. Use for module parameters, resource definitions, test/main.test.bicep scenarios, Bicep build and lint, PSRule analysis, or Azure deployment preflight validation."
---

# Azure Bicep Module Authoring

Use this workflow when adding or changing a reusable Azure Bicep module and its validation scenarios. Keep tests focused on module behavior; for general assertion design, also follow [test-discipline](../test-discipline/SKILL.md).

## Workflow

1. Find the module under `modules/<area>/<name>/` and read its `main.bicep`, `test/main.test.bicep`, and a nearby module with similar resources. Keep the module implementation in `main.bicep`.
2. Define the public interface with documented parameters and typed objects. Follow local conventions such as `@description` text that marks parameters Required or Optional, useful defaults, and `@allowed` constraints where the accepted values are limited. Keep resource names, API versions, and outputs appropriate to the module contract.
3. Add or update `test/main.test.bicep`. Compose the module with a relative path such as `../main.bicep`; use unique deployment-derived names where Azure resources require uniqueness. Include a minimal configuration and scenarios for meaningful optional settings, matching existing module tests. Tests that need prerequisite resources may declare them as `existing`.
4. This repo enables Bicep `testFramework` and `assertions` in `bicepconfig.json`, but its checked-in `main.test.bicep` files are deployment scenario templates. CI runs PSRule against that test template, then runs Azure preflight validation against the module with its configured parameters; do not assume a standalone `az bicep test` command.

## Focused validation

From the repository root, replace `<area>` and `<name>` with the module path:

```bash
az bicep build --file modules/<area>/<name>/main.bicep
az bicep build --file modules/<area>/<name>/test/main.test.bicep
PSRULE_AZURE_BICEP_USE_AZURE_CLI=true pwsh -NoLogo -Command 'Invoke-PSRule -InputPath modules/<area>/<name>/test/main.test.bicep'
```

The PSRule command requires Azure CLI with Bicep installed and the `PSRule.Rules.Azure` PowerShell module. For deployment preflight, use a signed-in Azure CLI context and the module's test resource group and parameters, following `.github/workflows/template-module.yml`:

```bash
az deployment group validate \
  --resource-group "<test-resource-group>" \
  --template-file "modules/<area>/<name>/main.bicep" \
  --parameters @modules/<area>/<name>/test/<parameters-file>.json
```

Use build for fast syntax and compile-time checks; PSRule checks Azure configuration guidance, while preflight checks the module against Azure without deploying it. If Azure credentials or a test resource group are unavailable, report preflight as not run rather than treating a successful build as equivalent.
