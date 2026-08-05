# App Configuration Store

This module deploys an Azure App Configuration Store.

## Details

Use this module within other Bicep templates to simplify the deployment and configuration of an App Configuration Store.

## Parameters

| Name | Type | Required | Description |
| :--- | :---: | :---: | :--- |
| `name` | `string` | Yes | Required. Name of the Azure App Configuration store. |
| `location` | `string` | Yes | Required. Location for all resources. |
| `tags` | `object` | Yes | Required. Tags of the resource. |
| `managedIdentities` | `managedIdentityAllType?` | No | Optional. The managed identity definition for this resource. |
| `sku` | `string` | No | Optional. Pricing tier of App Configuration. Allowed values: `Free`, `Developer`, `Standard`, `Premium`. Default is `Standard`. |
| `createMode` | `string` | No | Optional. Indicates whether the configuration store needs to be recovered. Allowed values: `Default`, `Recover`. Default is `Default`. |
| `disableLocalAuth` | `bool` | No | Optional. Disables all authentication methods other than AAD authentication. Default is `true`. |
| `enablePurgeProtection` | `bool` | No | Optional. Whether purge protection is enabled. Defaults to `true` unless `sku` is `Free` or `Developer`. |
| `publicNetworkAccess` | `string?` | No | Optional. Whether public network access is allowed. Allowed values: `Enabled`, `Disabled`. If not specified and private endpoints are set, defaults to `Disabled`. |
| `softDeleteRetentionInDays` | `int` | No | Optional. Number of days to retain the store when soft deleted. Must be between 1 and 7. Defaults to `1`, except `0` for `Free` and `Developer` SKU. |
| `keyValues` | `array?` | No | Optional. All key-values to create in the App Configuration Store. Requires local authentication to be enabled. |
| `replicaLocations` | `replicaLocationType[]?` | No | Optional. Replica locations to create. |
| `lock` | `lockType?` | No | Optional. The lock settings for the service. |
| `roleAssignments` | `roleAssignmentType[]?` | No | Optional. Array of role assignments to create. |
| `dataPlaneProxy` | `dataPlaneProxyType?` | No | Optional. Configuration for the data plane proxy. |
| `privateEndpoints` | `privateEndpointSingleServiceType[]?` | No | Optional. Configuration details for private endpoints. |

## Outputs

| Name | Type | Description |
| :--- | :---: | :--- |
| `name` | `string` | The name of the App Configuration Store. |
| `resourceId` | `string` | The resource ID of the App Configuration Store. |
| `systemAssignedMIPrincipalId` | `string?` | The principal ID of the system assigned identity, if enabled. |
| `endpoint` | `string` | The endpoint of the App Configuration Store. |
| `privateEndpoints` | `privateEndpointOutputType[]` | The private endpoints of the App Configuration Store. |

## Examples

### Example 1

Deploy the App Configuration Store with the minimum required parameters.

```bicep
module appConfig 'modules/config/app-configuration/main.bicep' = {
  name: 'appConfigStore'
  params: {
    name: 'my-app-config-store'
    location: 'uksouth'
    tags: {
      environment: 'production'
    }
  }
}
```

### Example 2

Deploy the App Configuration Store with private endpoints and role assignments.

```bicep
module appConfig 'modules/config/app-configuration/main.bicep' = {
  name: 'appConfigStore'
  params: {
    name: 'my-app-config-store'
    location: 'uksouth'
    tags: {
      environment: 'production'
    }
    privateEndpoints: [
      {
        subnetResourceId: '/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>'
        name: 'my-appconfig-pe'
      }
    ]
    roleAssignments: [
      {
        principalId: '<principal-id>'
        roleDefinitionIdOrName: 'App Configuration Data Reader'
      }
    ]
  }
}
```
