# Storage

This module deploy storage account.

## Details

Use this module within other Bicep template to simplify the usage of storage account.

## Parameters

| Name                    |            Type             | Required | Description                                                                                                    |
| :---------------------- | :-------------------------: | :------: | :------------------------------------------------------------------------------------------------------------- |
| `name`                  |          `string`           |   Yes    | Name of the Storage Account. Must be unique within Azure.                                                      |
| `location`              |          `string`           |   Yes    | Location for all resources.                                                                                    |
| `tags`                  |          `object`           |   Yes    | Tags to apply to the resources.                                                                                |
| `isZoneRedundant`       |           `bool`            |    No    | Defaults to `false`. When true, the default SKU is `Standard_ZRS` instead of `Standard_GRS`.                  |
| `sku`                   |          `string`           |    No    | Defaults to `Standard_GRS`, or `Standard_ZRS` when `isZoneRedundant` is true. Overrides the derived default.  |
| `kind`                  |          `string`           |    No    | Defaults to `StorageV2`.                                                                                       |
| `accessTier`            |          `string`           |    No    | Defaults to `Hot`. The access tier used for billing.                                                           |
| `allowBlobPublicAccess` |           `bool`            |    No    | Defaults to `false`. Controls public access to blobs and containers.                                           |
| `blobServiceProperties` | `blobServicePropertiesType` |    No    | Defaults to enabled blob and container deletion retention policies of 90 days.                                 |
| `blobContainers`        |   `blobContainerType[]`     |    No    | Defaults to an empty array. Blob containers to create for the Storage Account.                                |
| `networkAcls`           |      `networkAclsType`      |    No    | Defaults to denying network access unless allowed by a rule; Azure services are bypassed by default.           |

## Outputs

| Name         |   Type   | Description                            |
| :----------- | :------: | :------------------------------------- |
| `resourceId` | `string` | The resource ID of the storage account |
| `name`       | `string` | The name of the storage account        |

## Resource API versions

The Storage Account, Blob service, and Blob container resources use API version
`2026-06-01`.

## Examples

### Examples 1

Example of how to deploy a storage account using a minumum required parameters.

```bicep
module test1 'br:mmbicepmoduleregistry.azurecr.io/storage-account:0.1.12' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-sa'
  params: {
    name: 'az-sa-001'
    sku: 'Standard_GRS'
    location: 'uksouth'
    tags: {
        environment: 'production'
    }
  }
}
```
