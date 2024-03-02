# Key Vaults

This module deploy Key Vaults.

## Details

Use this module within other Bicep template to simplify the usage of a Key Vault.

## Parameters

| Name                        |    Type    | Required | Description                                                                                                                                                                                                                        |
| :-------------------------- | :--------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                      |  `string`  |   Yes    | Required. Name of Key Vault                                                                                                                                                                                                        |
| `location`                  |  `string`  |   Yes    | Required. Location for all resources                                                                                                                                                                                               |
| `tags`                      |  `object`  |   Yes    | Required. Tags of the resources                                                                                                                                                                                                    |
| `workspaceId`               |  `string`  |   Yes    | Required. Provide Log Analytics Workspace Id for diagnostics settings                                                                                                                                                              |
| `principalId`               |  `string`  |    No    | Optional. Provide Service Principal Id with access for the keyvault                                                                                                                                                                |
| `enableSoftDelete`          |   `bool`   |    No    | Optional. Specifies whether soft delete should be enabled for the Key Vault                                                                                                                                                        |
| `softDeleteRetentionInDays` |  `string`  |    No    | Optional. The number of days to retain deleted data in the Key Vault                                                                                                                                                               |
| `enablePurgeProtection`     |  `string`  |    No    | Optional. Specify whether purge protection should be enabled for the Key Vault                                                                                                                                                     |
| `enableRbacAuthorization`   |  `string`  |    No    | Optional. Specify whether the Key Vault will be using RBAC. Default is false - use the access policy                                                                                                                               |
| `skuName`                   |  `string`  |    No    | Optional. The SKU name of the Key Vault                                                                                                                                                                                            |
| `skuFamily`                 |  `string`  |    No    | Optional. The SKU family of the Key Vault                                                                                                                                                                                          |
| `networkAcls`               |  `string`  |    No    | Optional. Configuration for network access rules                                                                                                                                                                                   |
| `publicNetworkAccess`       |  `string`  |    No    | Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set |
| `lock`                      | `lockType` |    No    | Optional. The lock settings of the service                                                                                                                                                                                         |

## Outputs

| Name         |   Type   | Description                      |
| :----------- | :------: | :------------------------------- |
| `resourceId` | `string` | The resource ID of the key vault |
| `name`       | `string` | The name of the key vault        |

## Examples

### Example 1

Example of how to deploy a key vault using a minimum required parameters.

```bicep
module kv 'br:mmbicepmoduleregistry.azurecr.io/keyvault:0.1.5' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-kv'
  params: {
    name: 'az-kv-01'
    workspaceId: '1234abcd-def89-765a-9abc-def1234abcde'
    networkAcls: {
        bypass: 'AzureServices'
        defaultAction: 'Deny'
        ipAllowlist: [ '127.0.0.0/24' ]
    }
    principalId: '00000000-0000-0000-0000-000000000000'
    location: 'uksouth'
    tags: {
        environment: 'production'
    }
  }
}
```
