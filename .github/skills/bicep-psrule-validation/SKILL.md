---
name: bicep-psrule-validation
description: "Run and interpret PSRule.Rules.Azure validation for Bicep modules in this repository. Use when a module must pass the repository's PSRule checks."
---

# PSRule Validation for Bicep Modules

Use this skill with [bicep-module-authoring](../bicep-module-authoring/SKILL.md) when validating Azure configuration guidance for a module.

## What the repository checks

The shared workflow in `.github/workflows/template-module.yml` runs PSRule against:

```text
modules/<area>/<name>/test/main.test.bicep
```

It separately builds the module and later runs Azure deployment preflight against `main.bicep`. Passing PSRule is not evidence that Bicep tests or Azure preflight passed.

## Local run

Prerequisites: Azure CLI with Bicep installed, PowerShell (`pwsh`), and the `PSRule.Rules.Azure` module.

From the repository root:

```bash
PSRULE_AZURE_BICEP_USE_AZURE_CLI=true pwsh -NoLogo -Command 'Invoke-PSRule -InputPath modules/<area>/<name>/test/main.test.bicep'
```

In an interactive PowerShell session:

```powershell
$env:PSRULE_AZURE_BICEP_USE_AZURE_CLI = 'true'
Invoke-PSRule -InputPath modules/<area>/<name>/test/main.test.bicep
```

The environment variable tells PSRule to invoke Bicep through Azure CLI because Azure CLI's managed Bicep binary is not necessarily on `PATH`. Install the rules module if absent:

```powershell
Install-Module -Name 'PSRule.Rules.Azure' -Repository PSGallery -Scope CurrentUser
```

## When rules fail

1. Read the rule name, affected resource, and source path before changing code. Fix the underlying Bicep configuration when the rule identifies a real module issue.
2. If the test template has an intentional exception, follow existing repository PSRule conventions and scope the exception narrowly; do not suppress the rule globally merely to get a green run.
3. Rerun PSRule against the same test template and build both `main.bicep` and `test/main.test.bicep`.
4. Record any remaining warnings separately from errors. Do not claim Azure deployment preflight passed unless it was actually run.

For CI parity, inspect `.github/workflows/template-module.yml`; it applies the `PSRule.Rules.Azure` module to the test template, then uses a signed-in Azure context for `az deployment group validate` against the module source.
