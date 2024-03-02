# Key Vaults - Access policy

This module deploy Key Vaults Access Policy.

## Details

Use this module within other Bicep template to simplify the usage of a Key Vault Access Policy.

## Parameters

| Name                    |   Type   | Required | Description                                                                                                                                                                                                                             |
| :---------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `keyVaultName`          | `string` |   Yes    | Required. Name of Key Vault                                                                                                                                                                                                             |
| `objectId`              | `string` |   Yes    | Required. Object Id of a user, service principal or security group                                                                                                                                                                      |
| `applicationId`         | `string` |    No    | Optional. Application id of the client making request                                                                                                                                                                                   |
| `secretsPermissions`    | `array`  |    No    | Optional. Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge                                                                                         |
| `keyPermissions`        | `array`  |    No    | Optional. Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge                     |
| `certificatPermissions` | `array`  |    No    | Optional. Specify the permissions to certificates. Valid values are: all, backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update |
| `policyName`            | `string` |    No    | Optional. Name of Key Vault Access Policy                                                                                                                                                                                               |

## Examples

### Example 1

Example of how to deploy a key vault access policy using a minimum required parameters.

```bicep
module kv_access_policy '.br:mmbicepmoduleregistry.azurecr.io/keyvault-access-policy:0.1.2' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-access-policy'
  params: {
    keyVaultName: 'az-kv-01'
    objectId: '00000000-0000-0000-0000-000000000000'
    secretsPermissions: [ 'get', 'list', 'set', 'delete' ]
  }
}
```
