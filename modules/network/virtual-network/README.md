# Virtual Networks

This module deploys Virtual Networks.

## Details

Use this module within other Bicep templates to simplify the usage of a Virtual Network.

## Parameters

| Name | Type | Required | Default | Description |
| :--- | :--- | :------: | :------ | :---------- |
| `name` | `string` | Yes | — | Required. The Virtual Network (vNet) name. |
| `location` | `string` | Yes | — | Required. Azure region for the Virtual Network. |
| `tags` | `object` | Yes | — | Required. Tags applied to the Virtual Network and any new Network Security Group. |
| `addressPrefixes` | `array` | Yes | — | Required. One or more address prefixes for the Virtual Network. |
| `subnets` | `array` | No | `[]` | Optional. Subnets to deploy in the Virtual Network. |
| `lock` | `lockType?` | No | `null` | Optional. Management lock settings for the Virtual Network. |
| `newOrExistingNSG` | `string` | No | `'none'` | Optional. Whether to create a Network Security Group (`'new'`), use an existing one (`'existing'`), or not apply a default NSG (`'none'`). |
| `networkSecurityGroupName` | `string` | No | `uniqueString(resourceGroup().name, location)` | Optional. Name of the default Network Security Group used for subnets when `newOrExistingNSG` is `'new'` or `'existing'`. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]?` | No | `null` | Optional. Role assignments to create at the Virtual Network scope. |


### Parameter: `roleAssignments`

| Name                       |   Type   | Required | Description                                                                  |
| :------------------------- | :------: | :------: | :--------------------------------------------------------------------------- |
| `roleDefinitionIdOrName`                     | `string` |   Yes   | Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID  |
| `principalId`                     | `string` |   Yes   | Required. The principal ID of the principal (user/group/identity) to assign the role to. |
| `name`                     | `string` |   No   | Optional. The name (as GUID) of the role assignment. If not provided, a GUID will be generated.   |
| `principalType`                     | `string` |   No   | Optional. The principal type of the assigned principal ID. |
| `description`                     | `string` |   No   | Optional. The description of the role assignment.|
| `condition`                     | `string` |   No   | Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| `conditionVersion`                     | `string` |   No   | Optional. Version of the condition. |
| `delegatedManagedIdentityResourceId`                     | `string` |   No   | Optional. The Resource Id of the delegated managed identity resource. |

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
module vNet 'br:mmbicepmoduleregistry.azurecr.io/virtual-network:1.0.0' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-vnet'
  params: {
    name: 'az-vnet-01'
    location: 'uksouth'
    addressPrefixes: [ '10.0.0.0/16' ]
    tags: {
        environment: 'production'
    }
  }
}
```

### Example 2

Example of how to deploy a virtual network with subnets, network security groups and service endpoints.

```bicep
module vNet 'br:mmbicepmoduleregistry.azurecr.io/virtual-network:1.0.0' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-vnet'
  params: {
    name: 'az-vnet-01'
    location: 'uksouth'
    addressPrefixes: [ '10.0.0.0/16' ]
    tags: {
      environment: 'production'
    }
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
    lock: {
      name: 'lock-name'
      kind: 'CanNotDelete'
      notes: 'lock-notes'
    }
  }
}
```
