# Key Vaults - Secrets

This module deploy Key Vaults Secrets.

## Details

Use this module within other Bicep template to simplify the usage of a Key Vault Secrets.

## Parameters

| Name           |   Type   | Required | Description                 |
| :------------- | :------: | :------: | :-------------------------- |
| `keyVaultName` | `string` |   Yes    | Required. Name of Key Vault |
| `secretName`   | `string` |   Yes    | Required. Secret name       |
| `secretValue`  | `string` |   Yes    | Required. Secret value      |

## Examples

# Example 1

Example of how to deploy a key vault secrets using a minimum required parameters

```bicep
module kv_secret 'br:mmbicepmoduleregistry.azurecr.io/keyvault-secrets:0.1.2' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-secret'
  params: {
    keyVaultName: 'az-kv-01'
    secretName: 'secret-name'
    secretValue: 'secret-value'
  }
}
```
