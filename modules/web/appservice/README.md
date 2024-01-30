# Web Application

This module deploy App Service with App Service Plan.

## Details

Use this module within other Bicep templates to simplify the usage of a Web App Service with App Service Plan.

## Parameters

| Name                       |   Type   | Required | Description                                                                  |
| :------------------------- | :------: | :------: | :--------------------------------------------------------------------------- |
| `name`                     | `string` |   Yes    | Required. The App Service Name                                     |
| `location`                 | `string` |   Yes    | Required. Location name for the resource. default to resource group location |
| `tags`                     | `object` |   Yes    | Required. Tags of the resources                                              |
| `runtimeName` | `string` | Yes | Required. Provide a runtime name from the list (dotnet, dotnetcore, node, python, java). |
| `runtimeVersion` | `string` | Yes | Required. Provide a runtime version |
| `sku` | `object` | No | Optional. SKU for the App Service Plan |
| `applicationInsightsName` | `string` | No | Optional. Provide Application Insight Name. |
| `keyVaultName` | `string` | No | Optional. Provide Key Vault Name |
| `kind` | `string` | No | Optional. Kind of resource |
| `reserved` | `bool` | No | Optional. If Linux app service plan true, false otherwise.|

## Outputs

| Name                |   Type   | Description                             |
| :------------------ | :------: | :-------------------------------------- |
| `identityPrincipalId`        | `string` | The app service identity principal ID  |
| `appServiceName`              | `string` | The name of app service         |
| `appServiceUrl`       | `string`  | The public url for the app service      |
| `appServicePlanId` | `string`  | The app service plan ID |
| `appServicePlanName` | `string` | The app service plan name |

## Examples

### Example 1

Example of how to deploy a Web App using minimum required paramaetrs.

```bicep
module web 'br:mmbicepmoduleregistry.azurecr.io/appservice:0.1.1' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-app'
  params: {
    name: 'az-web-01'
    location: 'uksouth'
    tags: my_tags
    runtimeName: 'dotnet'
    runtimeVersion: '8-lts'
  }
}
```

### Example 2

Example of how to deploy production ready web app using node as a runtime engine running on linux with 2 instances to improve resiliance.

```bicep
module test2 '../main.bicep' = {
  name: 'test2'
  params: {
    name: 'az-web-01'
    location: 'uksouth'
    tags: my_tags
    sku: {
      name: 'S1'
      tier: 'Standard'
      capacity: 2
    }
    reserved: true
    runtimeName: 'node'
    runtimeVersion: '18-lts'
  }
}
```