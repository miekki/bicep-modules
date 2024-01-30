# Virtual Networks

This module deploys Virtual Networks.

## Details

Use this module within other Bicep templates to simplify the usage of a Virtual Network.

## Parameters

| Name                       |   Type   | Required | Description                                                                  |
| :------------------------- | :------: | :------: | :--------------------------------------------------------------------------- |
| `name`                     | `string` |   Yes    | Required. The Virual Network Name (vNet)                                     |
| `location`                 | `string` |   Yes    | Required. Location name for the resource. default to resource group location |
| `tags`                     | `object` |   Yes    | Required. Tags of the resources                                              |
| `addressPrefix`            | `array`  |   Yes    | Required. An array of one or more IP Address Prefix for the Virtual Network  |
| `subnets`                  | `array`  |    No    | Optional. An Array of subnets to deploy to the Virtual Network               |
| `lock`                     | `string` |    No    | Optional. Specify the type of the lock 'CanNotDelete' or 'ReadOnly'          |
| `newOrExistingNSG`         | `string` |    No    | Optional. Create a new, use an existing, or provide no default NSG           |
| `networkSecurityGroupName` | `string` |    No    | Optional. Name of default NSG to use for subnets                             |

## Outputs

| Name                |   Type   | Description                             |
| :------------------ | :------: | :-------------------------------------- |
| `resourceId`        | `string` | The resource ID of the virtual network  |
| `name`              | `string` | The name of the virtual network         |
| `subnetNames`       | `array`  | The names of the deployed subnets       |
| `subnetResourceIds` | `array`  | The resource ID of the deployed subnets |

## Examples

### Example 1

Example of how to deploy a virtual network using the minimum required parameters.

```bicep
module vNet 'br:mmbicepmoduleregistry.azurecr.io/virtual-network:1.0.35' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-vnet'
  params: {
    name: 'az-vnet-01'
    addressPrefixes: [ '10.0.0.0/16' ]
    location: 'uksouth'
    tags: {
        environment: 'production'
    }
  }
}
```

### Example 2

Example of how to deploy a virtual network with subnets, network security groups and service endpoints.

```bicep
module vNet 'br:mmbicepmoduleregistry.azurecr.io/virtual-network:1.0.35' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-vnet'
  params: {
    name: 'az-vnet-01'
    addressPrefixes: [ '10.0.0.0/16' ]
    subnets: [
     {
        name: 'frontend-subnet-01'
        addressPrefix: '10.0.1.0/24'
        networkSecurityGroupId: '/subscriptions/111111-1111-1111-1111-111111111111/resourceGroups/validation-rg/providers/Microsoft.Network/networkSecurityGroups/az-nsg-01'
      }
      {
        name: 'backend-subnet-01'
        addressPrefix: '10.0.2.0/24'
        networkSecurityGroupId: '/subscriptions/111111-1111-1111-1111-111111111111/resourceGroups/validation-rg/providers/Microsoft.Network/networkSecurityGroups/az-nsg-01'
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
          {
            service: 'Microsoft.Sql'
          }
        ]
        routeTableId: '/subscriptions/111111-1111-1111-1111-111111111111/resourceGroups/validation-rg/providers/Microsoft.Network/routeTables/az-rt-01'
      }

    ]
    location: 'uksouth'
    tags: {
      environment: 'production'
    }
    lock: 'CanNotDelete'
  }
}
```
