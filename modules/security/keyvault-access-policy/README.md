# Key Vaults - Access policy

This module adds, removes, or replaces an access policy on an existing Key Vault.

## Details

Use this module within another Bicep template to manage a Key Vault access policy. The module uses the stable `2026-05-15` Key Vault resource API.

## Parameters

| Name                    |   Type   | Required | Description |
| :---------------------- | :------: | :------: | :---------- |
| `keyVaultName`          | `string` |   Yes    | Name of the existing Key Vault. |
| `objectId`              | `string` |   Yes    | Object ID of the user, service principal, or security group receiving the permissions. |
| `applicationId`         | `string` |    No    | Application ID of the client making the request. Defaults to an empty value, which is omitted from the access policy. |
| `secretsPermissions`    | `array`  |    No    | Permissions for secrets: `all`, `get`, `list`, `set`, `delete`, `backup`, `restore`, `recover`, or `purge`. |
| `keyPermissions`        | `array`  |    No    | Permissions for keys: `all`, `encrypt`, `decrypt`, `wrapKey`, `unwrapKey`, `sign`, `verify`, `get`, `list`, `create`, `update`, `import`, `delete`, `backup`, `restore`, `recover`, `purge`, `release`, `rotate`, `getrotationpolicy`, or `setrotationpolicy`. |
| `certificatPermissions` | `array`  |    No    | Permissions for certificates: `all`, `backup`, `create`, `delete`, `deleteissuers`, `get`, `getissuers`, `import`, `list`, `listissuers`, `managecontacts`, `manageissuers`, `purge`, `recover`, `restore`, `setissuers`, or `update`. |
| `policyName`            | `string` |    No    | Access policy operation: `add` (default), `remove`, or `replace`. |

## Examples

### Example 1

Example of how to deploy a key vault access policy using a minimum required parameters.

```bicep
module kv_access_policy '.br:mmbicepmoduleregistry.azurecr.io/keyvault-access-policy:1.0.0' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-access-policy'
  params: {
    keyVaultName: 'az-kv-01'
    objectId: '00000000-0000-0000-0000-000000000000'
    secretsPermissions: [ 'get', 'list', 'set', 'delete' ]
  }
}
```

The Key Vault must already exist. The `policyName` value selects the operation on the access policy; it is not a custom policy name.
