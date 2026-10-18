# Changelog

## Unreleased

- Update the configuration store and key-value resources from
  `2025-02-01-preview` to the latest API version, `2025-08-01-preview`.
  The latest stable API version is `2024-06-01`, which is more than 700 days
  old as of 2026-10-18, so the newer preview version is used.
- Microsoft Learn reports no properties added, updated, or removed in
  `2025-08-01-preview` for either resource type. No breaking API changes were
  identified, and the module parameters and outputs are unchanged.
- Remove the stale `replicaLocations` parameter from the README; it is
  commented out and is not part of the module interface.
- Add a module-local PSRule test template covering the minimum configuration
  and optional key-value deployment.

- [Configuration store API reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
- [Configuration store API change log](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/change-log/configurationstores)
- [Key-value API reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/keyvalues)
- [Key-value API change log](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/change-log/configurationstores/keyvalues)
