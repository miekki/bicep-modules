# Changelog

## Unreleased

- Rename the network ACL resource access rule field to `resourceId` to match
  the Storage API type and avoid BCP037 warnings. The test fixture covers this
  input shape.
- Update the Storage Account, Blob service, and Blob container resource API
  versions to the latest stable `2026-09-01`.
- Correct the documented SKU defaults: `Standard_GRS` by default and
  `Standard_ZRS` when `isZoneRedundant` is true (unless `sku` is explicitly
  provided), and document `blobContainers` as an array.
- Add optional private endpoint deployment using the shared network module.
  Public network access is disabled by default when private endpoints are
  configured and can be explicitly overridden.
- Add `SecuredByPerimeter` public network access and the latest supported
  Storage Account access tiers.

- [Storage Account API reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
- [Blob service API reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices)
- [Blob container API reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices/containers)
- [Storage Account API change log](https://learn.microsoft.com/azure/templates/microsoft.storage/change-log/storageaccounts)
- [Blob service API change log](https://learn.microsoft.com/azure/templates/microsoft.storage/change-log/storageaccounts/blobservices)
- [Blob container API change log](https://learn.microsoft.com/azure/templates/microsoft.storage/change-log/storageaccounts/blobservices/containers)
