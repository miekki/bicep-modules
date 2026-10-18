# Changelog

## Unreleased

- Update the configuration store and key-value resources from
  `2025-02-01-preview` to the latest API version, `2025-08-01-preview`.
  The latest stable API version is `2024-06-01`, which is more than 700 days
  old as of 2026-10-18, so the newer preview version is used.
- Microsoft Learn reports no properties added, updated, or removed in
  `2025-08-01-preview` for either resource type. No breaking API changes were
  identified. Existing outputs remain unchanged; this follow-up adds optional
  parameters for replicas and diagnostic settings.
- Enable `replicaLocations` and add optional Log Analytics diagnostic settings
  to the module. The module-local PSRule test configures audit logs and a
  secondary replica so the App Configuration audit-log and geo-replication
  rules can validate the emitted resources. Diagnostic settings use
  `2021-05-01-preview` (the latest listed version with category-group support;
  the latest stable version is older than 700 days).

- [Configuration store API reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
- [Configuration store API change log](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/change-log/configurationstores)
- [Key-value API reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/keyvalues)
- [Key-value API change log](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/change-log/configurationstores/keyvalues)
- [Diagnostic settings API reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
