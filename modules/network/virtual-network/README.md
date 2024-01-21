# Virtual Networks

This module deploys Virtual Networks.

## Details

Use this module within other Bicep templates to simplify the usage of a Virtual Network.

## Parameters

| Name       |   Type   | Required | Description                                                                  |
| :--------- | :------: | :------: | :--------------------------------------------------------------------------- |
| `name`     | `string` |   Yes    | Required. The Virual Network Name (vNet)                                     |
| `location` | `string` |    No    | Optional. Location name for the resource. default to resource group location |

## Outputs

| Name                |   Type   | Description                             |
| :------------------ | :------: | :-------------------------------------- |
| `resourceId`        | `string` | The resource ID of the virtual network  |
| `name`              | `string` | The name of the virtual network         |
| `subnetsName`       | `array`  | The names of the deployed subnets       |
| `subnetsResourceId` | `array`  | The resource ID of the deployed subnets |

## Examples

### Example 1

Example of how to deploy a virtual network using the minimum required parameters.

```bicep
module vNet 'br/mmbicepmoduleregistry.azurecr.io/virtual-network:1.0.0' = {
    name: '${uniqueString(demployment().name)}-vnet'
    params: {
        name: 'my-app-vent'
        addressPrefixes: [
            '10.0.0.0/16'
        ]
    }
}
```
