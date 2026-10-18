# Key Vaults

This module deploys Key Vaults and configures diagnostics.

## Details

Use this module within other Bicep templates to simplify the deployment of a Key Vault, including network ACLs and diagnostic settings.

The Key Vault is deployed using the stable `Microsoft.KeyVault/vaults@2026-05-15` API.

## Parameters

| Name                        |    Type    | Required | Default | Description |
| :-------------------------- | :--------: | :------: | :-----: | :---------- |
| `name`                      | `string`   | Yes      | —       | Name of the Key Vault. |
| `location`                  | `string`   | Yes      | —       | Location for the Key Vault. |
| `tags`                      | `object`   | Yes      | —       | Tags applied to the Key Vault. |
| `workspaceId`               | `string`   | Yes      | —       | Log Analytics workspace resource ID used by the diagnostic setting. |
| `principalId`               | `string`   | No       | `''`    | Service principal object ID granted the `get` and `list` secret permissions through an access policy. |
| `enableSoftDelete`          | `bool`     | No       | `true`  | Whether soft delete is enabled. |
| `softDeleteRetentionInDays` | `int`      | No       | `7`     | Number of days to retain deleted data. |
| `enablePurgeProtection`     | `bool`     | No       | `false` | Whether purge protection is enabled. |
| `enableRbacAuthorization`   | `bool`     | No       | `true`  | Whether the Key Vault uses RBAC authorization. |
| `skuName`                   | `string`   | No       | `standard` | Key Vault SKU name (`standard` or `premium`). |
| `skuFamily`                 | `string`   | No       | `A`     | Key Vault SKU family. |
| `networkAcls`               | `networkAclsType` | No | `{ defaultAction: 'Deny' }` | Network access rules, including optional IP and subnet allowlists. |
| `publicNetworkAccess`       | `string`   | No       | `''`    | Public network access setting (`Enabled` or `Disabled`). When omitted, the service default applies. |
| `lock`                      | `lockType` | No       | `{}`    | Optional management lock (`CanNotDelete`, `ReadOnly`, or `None`). |

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
