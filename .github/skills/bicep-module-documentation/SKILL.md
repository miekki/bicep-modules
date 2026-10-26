---
name: bicep-module-documentation
description: "Write and maintain per-module README documentation that matches the current Bicep interface. Use when updating parameters, custom types, defaults, outputs, or usage examples."
---

# Bicep Module Documentation

Use this skill with [bicep-module-authoring](../bicep-module-authoring/SKILL.md) when creating or updating `modules/<area>/<name>/README.md`.

## Source of truth

Read the current `main.bicep` and imported shared types before editing; they are authoritative. Existing docs/examples may be stale—exclude parameters, outputs, and nested properties absent from the current interface.

## README requirements

- **Scope:** Describe actual deployment/configuration; do not claim unimplemented features (e.g., diagnostics).
- **Parameters:** Match names, types, requiredness, defaults, and behavior. Include `Default`; show the exact Bicep default (`[]`, literal, generated expression) or `null` for optional parameters without defaults.
- **Structured types:** Link each structured/custom parameter to a same-document property table. Recursively document nested custom objects, linking nested types and structured properties.
- **Outputs:** List every public output with its exact name and type.
- **Examples:** Keep snippets syntactically valid against the current interface; use imported types' actual property names. Key Vault grants use `roleAssignments` (not obsolete top-level `principalId`); private DNS groups use `privateDnsZoneGroup.privateDnsZoneGroupConfigs[].privateDnsZoneResourceId`.
- **Behavior:** Explain relevant defaults/conditionals, e.g., Key Vault public access is disabled by default when private endpoints are configured.
- **Coverage/version:** Include minimal and realistic feature examples. Follow the registry coordinate/version convention in the module README; avoid stale releases or unrelated values.

## Examples from this repository

- `modules/network/virtual-network/README.md`: parameter `Default` and linked `roleAssignments` table.
- `modules/security/keyvault/README.md`: custom network ACL, lock, role assignment, and private endpoint tables, including nested private DNS configuration.

## Validation

For documentation-only edits, run:

```bash
git diff --check -- modules/<area>/<name>/README.md
```

If extractable, build snippets against the current interface; otherwise, compare example parameters and nested properties with `main.bicep` and shared type declarations.
