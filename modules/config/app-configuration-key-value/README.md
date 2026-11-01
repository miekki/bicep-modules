# App Configuration Key-Value

This module deploys a key-value entry in an existing Azure App Configuration
store. It uses
`Microsoft.AppConfiguration/configurationStores/keyValues@2025-08-01-preview`.
Microsoft Learn lists `2024-06-01` as the latest stable API; it is 883 days old
as of 2026-11-01, so the preview version meets the 700-day threshold specified
for this review. The API change log reports no property changes in
`2025-08-01-preview`.

## Parameters

| Name | Type | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `appConfigurationName` | `string` | Yes | — | Name of the existing parent App Configuration store. |
| `name` | `string` | Yes | — | Name of the key-value entry. |
| `value` | `string` | Yes | — | Value stored for the key. |
| `contentType` | `string?` | No | `null` | Content type for the value. |
| `tags` | `object?` | No | `null` | Tags for the key-value entry. |

The module does not create the parent store. When deploying a key-value through
ARM, the store must allow local authentication while the deployment runs.

## Outputs

| Name | Type | Description |
| :--- | :--- | :--- |
| `name` | `string` | Name of the key-value resource. |
| `resourceId` | `string` | Resource ID of the key-value resource. |

## Examples

To see examples on how to use this module please check [sample-deployments.azcli](./examples/sample-deployments.azcli)
