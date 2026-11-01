# App Configuration Store

This module deploys an Azure App Configuration store with optional replicas,
diagnostic settings, key-values, role assignments, locks, and private
endpoints.

The store, replica, and nested key-value resources use
`Microsoft.AppConfiguration/configurationStores@2025-08-01-preview`. Microsoft
Learn lists `2024-06-01` as the latest stable API; it is 883 days old as of
2026-11-01, so the preview version meets the 700-day threshold specified for
this review. Diagnostic settings use the
latest listed `2021-05-01-preview` API because the latest stable version is
older than 700 days. The API change log reports no property changes in
`2025-08-01-preview`.

## Parameters

| Name | Type | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `string` | Yes | — | Name of the App Configuration store. |
| `location` | `string` | Yes | — | Azure region for the store and related resources. |
| `tags` | `object` | Yes | — | Tags applied to the store. |
| [`managedIdentities`](#parameter-managedidentities) | `managedIdentityAllType?` | No | `null` | System-assigned and user-assigned managed identity configuration. |
| `sku` | `string` | No | `'Standard'` | Pricing tier: `Free`, `Developer`, `Standard`, or `Premium`. |
| `createMode` | `string` | No | `'Default'` | Whether to create or recover the store: `Default` or `Recover`. |
| `disableLocalAuth` | `bool` | No | `true` | Disables authentication methods other than Microsoft Entra ID. Set to `false` when deploying `keyValues`. |
| `enablePurgeProtection` | `bool` | No | `true` | Purge protection. The module forces this to `false` for `Free` and `Developer` SKUs. |
| `publicNetworkAccess` | `string?` | No | `null` | `Enabled` or `Disabled`. Defaults to `Disabled` when private endpoints are configured, and `Enabled` otherwise. |
| `softDeleteRetentionInDays` | `int` | No | `1` | Retention period from 1–7 days. The module sets it to `0` for `Free` and `Developer` SKUs. |
| [`keyValues`](#parameter-keyvalues) | `array?` | No | `null` | Key-values to create in the store. Local authentication must be enabled (`disableLocalAuth: false`) while ARM provisions these values. |
| [`replicaLocations`](#parameter-replicalocations) | `replicaLocationType[]?` | No | `null` | Secondary store replicas. Replicas require the `Standard` SKU. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | `diagnosticSettingsType?` | No | `null` | Log categories or groups to send to an existing Log Analytics workspace. |
| [`lock`](#parameter-lock) | `lockType?` | No | `null` | Management lock configuration. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]?` | No | `null` | Role assignments at the store scope. |
| [`dataPlaneProxy`](#parameter-dataplaneproxy) | `dataPlaneProxyType?` | No | `null` | Data plane proxy authentication and private-link delegation settings. |
| [`privateEndpoints`](#parameter-privateendpoints) | `privateEndpointSingleServiceType[]?` | No | `null` | Private endpoints for the store. |

### Parameter: `managedIdentities`

| Name | Type | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `systemAssigned` | `bool?` | No | `false` | Enables a system-assigned identity. |
| `userAssignedResourceIds` | `string[]?` | No | `[]` | Resource IDs of user-assigned identities. |

### Parameter: `keyValues`

Each item supports these properties:

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `name` | `string` | Yes | Key name. |
| `value` | `string` | Yes | Value stored for the key. |
| `contentType` | `string?` | No | Content type for the value. |
| `tags` | `object?` | No | Tags for the key-value. Defaults to the store's `tags`. |

### Parameter: `replicaLocations`

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `replicaLocation` | `string` | Yes | Azure region for the replica. |
| `name` | `string?` | No | Replica name. If omitted, the module generates one. |

### Parameter: `diagnosticSettings`

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `workspaceId` | `string` | Yes | Resource ID of an existing Log Analytics workspace. |
| `logs` | `object[]` | Yes | Log categories or category groups to enable. |

Each `logs` item has:

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `category` | `string?` | No | Log category. |
| `categoryGroup` | `string?` | No | Log category group. |
| `enabled` | `bool` | Yes | Whether the selected category or group is enabled. |

### Parameter: `lock`

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `kind` | `'CanNotDelete' \| 'ReadOnly' \| 'None'` | Yes | Lock level. |
| `name` | `string?` | No | Lock name. If omitted, the module generates one. |
| `notes` | `string?` | No | Lock notes. |

### Parameter: `roleAssignments`

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `roleDefinitionIdOrName` | `string` | Yes | Supported built-in role display name, role-definition GUID, or full role-definition resource ID. |
| `principalId` | `string` | Yes | Object ID of the principal receiving the role. |
| `name` | `string?` | No | Role assignment GUID. If omitted, one is generated. |
| `principalType` | `'ServicePrincipal' \| 'Group' \| 'User' \| 'ForeignGroup' \| 'Device'` | No | Type of principal. |
| `description` | `string?` | No | Role assignment description. |
| `condition` | `string?` | No | Role assignment condition. |
| `conditionVersion` | `'2.0'?` | No | Version of the condition. |
| `delegatedManagedIdentityResourceId` | `string?` | No | Delegated managed identity resource ID. |

### Parameter: `dataPlaneProxy`

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `authenticationMode` | `'Local' \| 'Pass-through'?` | No | Authentication mode. Defaults to `Pass-through`. |
| `privateLinkDelegation` | `'Disabled' \| 'Enabled'` | Yes | Whether delegated Azure Resource Manager private-link requests are allowed. |

### Parameter: `privateEndpoints`

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `subnetResourceId` | `string` | Yes | Subnet resource ID for the endpoint. |
| `name` | `string?` | No | Endpoint name. |
| `location` | `string?` | No | Endpoint region. If omitted, inferred from the subnet. |
| `service` | `string?` | No | Private Link subresource. Defaults to `configurationStores`. |
| `privateLinkServiceConnectionName` | `string?` | No | Private Link connection name. |
| `resourceGroupResourceId` | `string?` | No | Resource group in which to create the endpoint. |
| `isManualConnection` | `bool?` | No | Whether the connection requires manual approval. |
| `manualConnectionRequestMessage` | `string?` | No | Request message, up to 140 characters. |
| [`privateDnsZoneGroup`](#parameter-private-dns-zone-group) | `privateEndpointPrivateDnsZoneGroupType?` | No | Private DNS zone group. |
| [`customDnsConfigs`](#parameter-custom-dns-configurations) | `privateEndpointCustomDnsConfigType[]?` | No | Custom DNS configurations. |
| [`ipConfigurations`](#parameter-ip-configurations) | `privateEndpointIpConfigurationType[]?` | No | Static endpoint IP configurations. |
| `applicationSecurityGroupResourceIds` | `string[]?` | No | Application security group resource IDs. |
| `customNetworkInterfaceName` | `string?` | No | Custom network interface name. |
| [`lock`](#parameter-lock) | `lockType?` | No | Endpoint lock. Defaults to the store lock. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]?` | No | Role assignments for the endpoint. |
| `tags` | `object?` | No | Endpoint tags. Defaults to the store tags. |
| `privateDnsZoneName` | `string?` | No | Name of a private DNS zone in the endpoint resource group. |
| `privateDnsZoneId` | `string?` | No | Resource ID of an existing private DNS zone. |

### Parameter: Private DNS zone group

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `name` | `string?` | No | DNS zone group name. |
| `privateDnsZoneGroupConfigs` | `object[]` | Yes | DNS zone associations (up to five). |

Each `privateDnsZoneGroupConfigs` item has:

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `privateDnsZoneResourceId` | `string` | Yes | Private DNS zone resource ID. |
| `name` | `string?` | No | Configuration name. |

### Parameter: Custom DNS configurations

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `fqdn` | `string?` | No | Fully qualified domain name for the endpoint IP. |
| `ipAddresses` | `string[]` | Yes | Private IP addresses for the endpoint. |

### Parameter: IP configurations

| Name | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `name` | `string` | Yes | Name unique within the resource group. |
| `properties` | `object` | Yes | Static IP configuration properties. |

Each `properties` object has required `groupId`, `memberName`, and
`privateIPAddress` string properties.

## Outputs

| Name | Type | Description |
| :--- | :--- | :--- |
| `name` | `string` | Name of the App Configuration store. |
| `resourceId` | `string` | Resource ID of the store. |
| `systemAssignedMIPrincipalId` | `string?` | System-assigned identity principal ID, if enabled. |
| `endpoint` | `string` | Store endpoint URI. |
| `privateEndpoints` | `privateEndpointOutputType[]` | Deployed private endpoint details. Each item contains `name`, `resourceId`, `groupId`, `customDnsConfigs`, and `networkInterfaceResourceIds`. |

## Examples

The minimal example uses the three required parameters:

```bicep
module appConfiguration 'modules/config/app-configuration/main.bicep' = {
  name: 'appConfiguration'
  params: {
    name: 'appconfig-example'
    location: 'uksouth'
    tags: {
      environment: 'sample'
    }
  }
}
```

See the [required-parameters example](examples/required-parameters/main.bicep),
[full-parameters example](examples/full-parameters/main.bicep), and
[sample deployment commands](examples/sample-deployments.azcli) for complete,
deployable examples. The full example expects an existing Log Analytics
workspace. For private access, configure `privateEndpoints` and set
`publicNetworkAccess` to `Disabled`.
