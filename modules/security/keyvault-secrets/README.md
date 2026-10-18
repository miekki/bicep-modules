# Key Vault - Secret

This module creates a secret in an existing Azure Key Vault.

## Details

The module uses the stable `Microsoft.KeyVault/vaults/secrets@2026-05-15` API.
The Key Vault must already exist, and the deployment identity must have
permission to write secrets to it.

## Parameters

| Name           |   Type   | Required | Description |
| :------------- | :------: | :------: | :---------- |
| `keyVaultName` | `string` | Yes | Name of the existing Key Vault. |
| `secretName`   | `string` | Yes | Name of the secret to create. |
| `secretValue`  | `string` | Yes | Secret value. This is a secure parameter and is not returned by the ARM deployment API. |

## Outputs

This module has no outputs.

## Examples

### Example 1

Create a secret in an existing Key Vault. Supply `secretValue` securely from
the calling deployment rather than hard-coding a production value.

```bicep
@secure()
param secretValue string

module kv_secret 'br:mmbicepmoduleregistry.azurecr.io/keyvault-secrets:0.1.2' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-secret'
  params: {
    keyVaultName: 'az-kv-01'
    secretName: 'secret-name'
    secretValue: 'secret-value'
  }
}
```
