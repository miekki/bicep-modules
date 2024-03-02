# Storage

This module deploy storage account.

## Details

Use this module within other Bicep template to simplify the usage of storage account.

## Parameters

| Name                    |            Type             | Required | Description                                                                                            |
| :---------------------- | :-------------------------: | :------: | :----------------------------------------------------------------------------------------------------- |
| `name`                  |          `string`           |   Yes    | Required. Name of Storage Account. Must be unique within Azure                                         |
| `location`              |          `string`           |   Yes    | Required. Location for all resources                                                                   |
| `tags`                  |          `object`           |   Yes    | Required. Tags of the resources                                                                        |
| `isZoneRedundant`       |           `bool`            |    No    | Optional. This toggle changes the default value of the sku parameter from Standard_LRS to Standard_ZRS |
| `sku`                   |          `string`           |    No    | Optional. Storage Account SKU. default is Standard_LRS                                                 |
| `kind`                  |          `string`           |    No    | Optional. Storage Account Kind. Default is StorageV2                                                   |
| `accessTier`            |          `string`           |    No    | Optional. The access tier of the storage account, which is used for billing                            |
| `allowBlobPublicAccess` |           `bool`            |    No    | Optional. Allow or disallow public access to all blobs or containers in the storage account            |
| `blobServiceProperties` | `blobServicePropertiesType` |    No    | Optional. Properties object for a Blob service of a Storage Account                                    |
| `blobContainers`        |     `blobContainerType`     |    No    | Optional. Array of blob containers to be created for blobServices of Storage Account                   |
| `networkAcls`           |      `networkAclsType`      |    No    | Optional. Configuration for network access rules                                                       |

## Outputs

| Name         |   Type   | Description                            |
| :----------- | :------: | :------------------------------------- |
| `resourceId` | `string` | The resource ID of the storage account |
| `name`       | `string` | The name of the storage account        |

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
