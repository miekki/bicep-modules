---
name: bicep-module-testing
description: "Design and run Bicep module test scenarios and assertions in this repository. Use when adding test/main.test.bicep cases or checking module behavior."
---

# Bicep Module Testing

Use this skill with [bicep-module-authoring](../bicep-module-authoring/SKILL.md) when adding reusable Azure Bicep module tests. General assertion-quality guidance is in [test-discipline](../test-discipline/SKILL.md).

## Test design

- Read the module source and existing test first. Keep `test/main.test.bicep` scenarios focused on public inputs and behavior.
- Include a minimal required-parameters case and meaningful optional-setting coverage; omit an "everything is set" case unless it adds distinct behavior.
- Assert observable contract details, not compile success alone. For input-derived values, expose the transformed value as a variable or assert the expression derived from inputs.
- Test default and override branches for conditional behavior when feasible. Examples: Key Vault network ACL mapping and explicit/implicit public network access; Virtual Network subnet projections and lock properties matching inputs.
- Avoid live Azure resource IDs except for pass-through tests. Bicep unit tests must not require a signed-in Azure session.
- Match the current API: Key Vault role assignments use the `roleAssignments` array, not the removed top-level `principalId` input.

## Bicep test framework constraints

The repository enables `testFramework` and `assertions` in `bicepconfig.json`. The local CLI has no `az bicep test`; run:

```bash
az bicep build --file modules/<area>/<name>/main.bicep
az bicep build --file modules/<area>/<name>/test/main.test.bicep
az bicep run --command "test modules/<area>/<name>/test/main.test.bicep"
```

Assertions compiling to ARM `reference()` of a resource are not locally evaluable and may cause a test case to be skipped; prefer parameter-derived variables and generated configuration objects. Cases requiring unsupported ARM loop functions such as `copyIndex()` may also be skipped. Distinguish these evaluator limits from failures and validate affected behavior with build, PSRule, or preflight as appropriate.

## Validation and mutation checks

- Build both module and test file, then run the Bicep test command above.
- Inspect the evaluation summary: skips are not passes. Investigate each reason, revise the test, or report why another validation layer is needed.
- For a critical assertion, temporarily mutate the actual protected expression and rerun the test to prove it fails; restore the expression and rerun. Never leave the mutation in the final change.
- `az deployment group validate` is not a unit test: it requires Azure authentication and the repository's configured test resource group.
