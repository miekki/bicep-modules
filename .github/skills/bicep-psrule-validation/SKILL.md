---
name: bicep-psrule-validation
description: "Run and interpret PSRule.Rules.Azure validation for Bicep modules in this repository. Use when a module must pass the repository's PSRule checks."
---

# PSRule Validation for Bicep Modules

Use with [bicep-module-authoring](../bicep-module-authoring/SKILL.md) to validate a module's Azure configuration guidance.

## CI checks

`.github/workflows/template-module.yml` runs PSRule on `modules/<area>/<name>/test/main.test.bicep`, separately builds the module, then runs Azure deployment preflight on `main.bicep`. PSRule success alone does not mean the build or preflight passed.

## Prerequisites and local run

Requires Azure CLI with Bicep, PowerShell (`pwsh`), and `PSRule.Rules.Azure`.

From the repository root:

```bash
PSRULE_AZURE_BICEP_USE_AZURE_CLI=true pwsh -NoLogo -Command 'Invoke-PSRule -InputPath modules/<area>/<name>/test/main.test.bicep'
```

The environment variable makes PSRule invoke Bicep through Azure CLI; its managed Bicep binary may not be on `PATH`. If needed, install the rules module:

```powershell
Install-Module -Name 'PSRule.Rules.Azure' -Repository PSGallery -Scope CurrentUser
```

## If rules fail

- Inspect the rule, affected resource, and source path; fix root Bicep configuration for real module issues.
- For intentional test-template exceptions, follow repository conventions and scope narrowly; never suppress rules globally just to pass.
- Rerun PSRule on the same test template and build `main.bicep` and `test/main.test.bicep`.
- Report warnings separately from errors. Claim preflight passed only if it was run.

For CI parity, the workflow applies `PSRule.Rules.Azure` to the test template, then runs `az deployment group validate` against the module source with a signed-in Azure context.
