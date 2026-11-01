# Changelog

## Unreleased

- Update the configuration store and key-value resources from
  `2025-02-01-preview` to the latest API version, `2025-08-01-preview`.
  The latest stable API version is `2024-06-01`, which is more than 700 days
  old as of 2026-11-01, so the newer preview version is used.
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
- The key-value test enables local authentication because provisioning its
  child key-value requires it. A PSRule suppression group, matched only by a
  test-only tag on that fixture store, scopes the expected AZR-000291 exception
  without excluding the rule for other resources.
- Add assertions and Bicep tests for SKU-dependent retention/protection and
  public-network-access defaults. Keep resource-expansion fixtures separate
  from unit tests so the Bicep evaluator can run every assertion.
- Add required/full-parameter deployment examples and link the Azure CLI
  deployment sample from this README. No public module parameters or outputs
  were removed or renamed.
- Verify companion resource APIs against Microsoft Learn: replicas remain on
  `2025-08-01-preview`, diagnostic settings use the latest listed
  `2021-05-01-preview` API because the latest stable API is older than 700 days,
  locks use the latest `2020-05-01` API, and role assignments use the latest
  stable `2022-04-01` API.

- [Configuration store API reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
- [Configuration store API change log](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/change-log/configurationstores)
- [Key-value API reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/keyvalues)
- [Key-value API change log](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/change-log/configurationstores/keyvalues)
- [Replica API reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/replicas)
- [Replica API change log](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/change-log/configurationstores/replicas)
- [Diagnostic settings API reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
- [Diagnostic settings API change log](https://learn.microsoft.com/azure/templates/microsoft.insights/change-log/diagnosticsettings)
- [Resource locks API reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/locks)
- [Resource locks API change log](https://learn.microsoft.com/azure/templates/microsoft.authorization/change-log/locks)
- [Role assignments API reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments)
- [Role assignments API change log](https://learn.microsoft.com/azure/templates/microsoft.authorization/change-log/roleassignments)