---
name: bicep-module-testing
description: "Design and run Bicep module test scenarios and assertions in this repository. Use when adding test/main.test.bicep cases or checking module behavior."
---

# Bicep Module Testing

Use this skill with [bicep-module-authoring](../bicep-module-authoring/SKILL.md) when adding reusable Azure Bicep module tests. General assertion-quality guidance is in [test-discipline](../test-discipline/SKILL.md).

## Test design

1. Read the module source and existing test file first. Keep `test/main.test.bicep` scenarios focused on public module inputs and behavior.
2. Include a minimal required-parameters case and one or more cases covering meaningful optional settings. Avoid an unnecessary "everything is set" case if it adds no distinct behavioral coverage.
3. Assert observable contract details rather than merely asserting that deployment compilation succeeded. For input-derived values, expose the transformed value as a variable or assert the expression derived from inputs.
4. Cover both default and override branches for conditional behavior when feasible. The Key Vault tests cover network ACL input mapping and explicit/implicit public network access; the Virtual Network module asserts that subnet projections and lock properties match their inputs.
5. Do not put live Azure resource IDs in a test unless only testing pass-through behavior. Do not require a signed-in Azure session to execute Bicep unit tests.
6. Keep tests consistent with the current module API. For example, Key Vault role assignments use the `roleAssignments` array, not a removed top-level `principalId` input.

## Bicep test framework constraints

This repository enables `testFramework` and `assertions` in `bicepconfig.json`. The local CLI does not expose `az bicep test`; use:

```bash
az bicep build --file modules/<area>/<name>/main.bicep
az bicep build --file modules/<area>/<name>/test/main.test.bicep
az bicep run --command "test modules/<area>/<name>/test/main.test.bicep"
```

Assertions that compile to ARM `reference()` of a resource are not locally evaluable by the test runner and can cause a test case to be skipped. Prefer assertions against parameter-derived variables and generated configuration objects. Likewise, test cases that require unsupported ARM loop functions such as `copyIndex()` may be skipped by the local evaluator; separate that limitation from test failures and cover the behavior with build, PSRule, or preflight as appropriate.

## Validation and mutation checks

- Run the Bicep build for both module and test file, then run the Bicep test command above.
- Inspect the evaluation summary: skipped cases are not passing evidence. Investigate skip reasons and revise the test or report why the behavior needs another validation layer.
- For a critical assertion, temporarily mutate the actual expression it protects, rerun the test to confirm it fails, then restore the correct expression and rerun. Do not leave the mutation in the final change.
- Keep `az deployment group validate` distinct from unit tests: it requires Azure authentication and the repository's configured test resource group.
