# Private DNS Zones

This module deploys a private DNS zone and optional child resources such as virtual network links and A records.

## Details

Use this module within other Bicep templates to simplify the deployment and management of Azure Private DNS zones with RBAC, locks, and virtual network links.

The module targets the stable `Microsoft.Network/privateDnsZones@2024-06-01` API.

## Parameters

| Name | Type | Required | Default | Description |
| :--- | :--- | :------: | :------ | :---------- |
| `name` | `string` | Yes | — | Name of the private DNS zone. |
| `tags` | `object` | Yes | — | Tags applied to the private DNS zone. |
| `lock` | `lockType?` | No | `null` | Optional management lock for the private DNS zone. |
| [`virtualNetworkLinks`](#parameter-virtualnetworklinks) | `virtualNetworkLinkType[]?` | No | `null` | Optional virtual network links to associate with the zone. |
| [`a`](#parameter-a) | `aType[]?` | No | `null` | Optional A records to create in the zone. |
| `location` | `string` | No | `'global'` | Azure location for the resource; Private DNS zones are global. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]?` | No | `null` | Optional RBAC role assignments scoped to the private DNS zone. |

### Parameter: `virtualNetworkLinks`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `name` | `string` | No | Name of the virtual network link. If omitted, the module derives one from the target virtual network. |
| `virtualNetworkResourceId` | `string` | Yes | Resource ID of the virtual network to link. |
| `location` | `string` | No | Region for the link resource; defaults to `'global'`. |
| `registrationEnabled` | `bool` | No | Whether automatic registration for the linked virtual network is enabled. |
| `tags` | `object` | No | Tags applied to the virtual network link. |
| `resolutionPolicy` | `'Default' \| 'NxDomainRedirect'` | No | Optional fallback resolution policy applied to the virtual network link when specified. |

### Parameter: `a`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `name` | `string` | Yes | Name of the A record. |
| `metadata` | `object` | No | Metadata attached to the record set. |
| `ttl` | `int` | No | Time to live in seconds. Defaults to `3600`. |
| `roleAssignments` | `roleAssignmentType[]?` | No | Optional role assignments scoped to the record set. |
| `aRecords` | `object[]` | No | A record values, such as `[{ ipv4Address: '10.0.0.4' }]`. |

### Parameter: `roleAssignments`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `roleDefinitionIdOrName` | `string` | Yes | Built-in role display name, GUID, or full resource ID. |
| `principalId` | `string` | Yes | Object ID of the principal receiving the role assignment. |
| `name` | `string` | No | Role assignment name. If omitted, one is generated. |
| `principalType` | `'ServicePrincipal' \| 'Group' \| 'User' \| 'ForeignGroup' \| 'Device'` | No | Type of the principal. |
| `description` | `string` | No | Description of the role assignment. |
| `condition` | `string` | No | Optional role assignment condition. |
| `conditionVersion` | `'2.0'` | No | Optional condition version. |
| `delegatedManagedIdentityResourceId` | `string` | No | Resource ID of a delegated managed identity. |

## Outputs

| Name | Type | Description |
| :--- | :--- | :---------- |
| `name` | `string` | The name of the private DNS zone. |
| `resourceId` | `string` | The resource ID of the private DNS zone. |

## Examples

To see examples on how to use this module please check [sample-deployments.azcli](./examples/sample-deploymments.azcli)