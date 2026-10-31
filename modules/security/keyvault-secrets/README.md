# Key Vault - Secret

This module creates a secret in an existing Azure Key Vault.

## Details

The module uses the stable `Microsoft.KeyVault/vaults/secrets@2026-05-15` API.
The Key Vault must already exist, and the deployment identity must have
permission to write secrets to it.

## Parameters

| Name           |   Type   | Required | Default | Description |
| :------------- | :------: | :------: | :-: | :---------- |
| `keyVaultName` | `string` | Yes | - | Name of the existing Key Vault. |
| `name`   | `string` | Yes | - | Name of the secret to create. |
| `value`  | `string` | Yes | - | Secret value. This is a secure parameter and is not returned by the ARM deployment API. |
| `tags`  | `object` | No | - | Resource tags. |
| `enabled`  | `bool` | No | `true` | Resource tags. |
| `expiryDateInSeconds`  | `int?` | No | - | Expiry date in seconds since 1970-01-01T00:00:00Z. For security reasons, it is recommended to set an expiration date whenever possible. |
| `notBeforeDateInSecounds`  | `int?` | No | - | Not before date in seconds since 1970-01-01T00:00:00Z. |
| `contentType`  | `string?` | No | - | The content type of the secret. |


## Outputs

| Name         | Type     | Description |
| :----------- | :------- | :---------- |
| `resourceId` | `string` | The resource ID of the secret. |
| `name`       | `string` | The name of the secret. |
| `secretUri`        | `string` | The uri of the secret. |
| `secretUriWithVersion`        | `string` | The uri with version of the secret.|


## Examples

To see examples on how to use this module please check [sample-deployments.azcli](./examples/sample-deployments.azcli)
