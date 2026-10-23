---
name: bicep-module-documentation
description: "Write and maintain per-module README documentation that matches the current Bicep interface. Use when updating parameters, custom types, defaults, outputs, or usage examples."
---

# Bicep Module Documentation

Use this skill with [bicep-module-authoring](../bicep-module-authoring/SKILL.md) when creating or updating `modules/<area>/<name>/README.md`.

## Source of truth

Treat the module's current `main.bicep` and imported shared types as authoritative. Read them before editing the README. Existing docs can be stale: do not retain parameters, outputs, or nested object properties just because they appear in an older README or example.

## README content

1. Describe what the module actually deploys and configures. Avoid claiming features such as diagnostics unless they are implemented in the current module.
2. Keep the parameter table synchronized with parameter names, types, requiredness, defaults, and behavior. Include a Default column and represent Bicep defaults accurately (`[]`, a literal, a generated expression, or `null` for an optional parameter without a default).
3. Link each structured/custom parameter to a property table in the same document. Document nested custom objects recursively, using links for nested types and properties that are themselves structured.
4. Document every public output, using its exact name and type from the module.
5. Keep examples syntactically valid against the current interface and use the actual property names of imported shared types. Use `roleAssignments` for the Key Vault's role grants; do not show an obsolete top-level `principalId`. For a Key Vault private DNS zone group, use `privateDnsZoneGroup.privateDnsZoneGroupConfigs[].privateDnsZoneResourceId`.
6. Explain relevant defaults and conditional behavior, such as Key Vault public access being disabled by default when private endpoints are configured.
7. Prefer a minimal example and a realistic feature example. Use the published registry coordinate/version convention already established in the module's README; avoid stale releases or unrelated values.

## Examples from this repository

- `modules/network/virtual-network/README.md` demonstrates the parameter default column and a linked property table for `roleAssignments`.
- `modules/security/keyvault/README.md` demonstrates tables for the custom network ACL, lock, role assignment, and private endpoint input types, including nested private DNS configuration.

## Validation

For documentation-only edits, run:

```bash
git diff --check -- modules/<area>/<name>/README.md
```

When code snippets can be extracted into a Bicep file, build them against the current module interface. Otherwise, compare each example's module parameters and nested properties directly with `main.bicep` and shared type declarations.
