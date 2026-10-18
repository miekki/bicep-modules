# Changelog

## Unreleased

- Rename the network ACL resource access rule field to `resourceId` to match
  the Storage API type and avoid BCP037 warnings. The test fixture covers this
  input shape.
- Update the Storage Account, Blob service, and Blob container resource API
  versions from `2026-04-01` to the latest stable `2026-06-01`.
- Microsoft Learn reports no properties added, updated, or removed for the
  Blob service and Blob container APIs. The Storage Account API adds
  `requireUserBoundUserDelegationSas`, `requireUserBoundUserDelegationSasAction`,
  and `allowCrossTenantDelegationSas`; this module does not use those properties.
  No properties are reported as removed or updated, so no breaking API changes
  relevant to the module were identified. Module parameters and outputs are
  unchanged.
- Correct the documented SKU defaults: `Standard_GRS` by default and
  `Standard_ZRS` when `isZoneRedundant` is true (unless `sku` is explicitly
  provided), and document `blobContainers` as an array.

- [Storage Account API reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
- [Blob service API reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices)
- [Blob container API reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices/containers)
- [Storage Account API change log](https://learn.microsoft.com/azure/templates/microsoft.storage/change-log/storageaccounts)
- [Blob service API change log](https://learn.microsoft.com/azure/templates/microsoft.storage/change-log/storageaccounts/blobservices)
- [Blob container API change log](https://learn.microsoft.com/azure/templates/microsoft.storage/change-log/storageaccounts/blobservices/containers)
