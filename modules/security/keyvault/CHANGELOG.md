# Changelog

## Unreleased

- Update Key Vault resource references to the latest stable `2026-02-01` API.
- Update diagnostic settings from stable `2016-09-01` to the latest listed
  `2021-05-01-preview` API because the latest stable version is more than 700
  days old. This API removes the unsupported `location` property and adds
  `systemData`.
- Keep resource locks at `2020-05-01` and role assignments at `2022-04-01`,
  the latest stable versions listed by Microsoft Learn.
- Correct README parameter types, defaults, and public network access behavior.

The Key Vault API change log reports no properties added, updated, or removed
in `2026-02-01` compared with `2025-05-01`. The diagnostic settings API change
log reports the `location` removal and `systemData` addition for
`2021-05-01-preview`; neither changes the module parameters or outputs. The
resource lock and role assignment API references have no newer stable versions.
Their current versions add `systemData` compared with older versions; the
module does not set that read-only metadata.

- [Key Vault API versions](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)
- [Key Vault API change log](https://learn.microsoft.com/azure/templates/microsoft.keyvault/change-log/vaults)
- [Diagnostic settings API versions](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
- [Diagnostic settings API change log](https://learn.microsoft.com/azure/templates/microsoft.insights/change-log/diagnosticsettings)
- [Resource locks API versions](https://learn.microsoft.com/azure/templates/microsoft.authorization/locks)
- [Resource locks API change log](https://learn.microsoft.com/azure/templates/microsoft.authorization/change-log/locks)
- [Role assignments API versions](https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments)
- [Role assignments API change log](https://learn.microsoft.com/azure/templates/microsoft.authorization/change-log/roleassignments)
