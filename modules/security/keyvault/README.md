# Key Vaults

This module deploys and configures Azure Key Vaults.

## Details

Use this module within other Bicep templates to deploy a Key Vault with configurable authorization, network ACLs, private endpoints, role assignments, and a management lock.

The Key Vault is deployed using the stable `Microsoft.KeyVault/vaults@2026-05-15` API.
When private endpoints are configured, public network access is disabled unless explicitly overridden. To configure private DNS, provide the `privatelink.vaultcore.azure.net` zone resource ID in the private endpoint's DNS zone group. The zone and its virtual network link must be provisioned in a network reachable by consumers.

## Parameters

| Name                        | Type                            | Required | Default                    | Description |
| :-------------------------- | :------------------------------ | :------: | :------------------------- | :---------- |
| `name`                      | `string`                        | Yes      | —                          | Name of the Key Vault. |
| `location`                  | `string`                        | Yes      | —                          | Azure region for the Key Vault. |
| `tags`                      | `object`                        | Yes      | —                          | Tags applied to the Key Vault and, unless overridden, its private endpoints. |
| `enableSoftDelete`          | `bool`                          | No       | `true`                     | Whether soft delete is enabled. |
| `softDeleteRetentionInDays` | `int`                           | No       | `90`                       | Number of days to retain deleted data (7–90). |
| `enablePurgeProtection`     | `bool`                          | No       | `true`                     | Whether purge protection is enabled. Once enabled, purge protection cannot be disabled. |
| `enableRbacAuthorization`   | `bool`                          | No       | `true`                     | Whether the Key Vault uses RBAC authorization. |
| `skuName`                   | `string`                        | No       | `standard`                 | Key Vault SKU name (`standard` or `premium`). |
| `skuFamily`                 | `string`                        | No       | `A`                        | Key Vault SKU family (`A` or `B`). |
| [`networkAcls`](#parameter-networkacls) | `networkAclsType` | No | `{ defaultAction: 'Deny' }` | Network access rules with a default action and optional IP and subnet allowlists. `bypass` supports `AzureServices` or `None` and defaults to `None`. |
| `publicNetworkAccess`       | `string`                        | No       | `''`                       | `Enabled` or `Disabled`. When omitted, public access is disabled if private endpoints are configured and enabled otherwise. Network ACLs still apply. |
| [`lock`](#parameter-lock) | `lockType?` | No | `null` | Optional management lock (`CanNotDelete`, `ReadOnly`, or `None`), with optional name and notes. |
| [`privateEndpoints`](#parameter-privateendpoints) | `privateEndpointSingleServiceType[]?` | No | `null` | Private endpoints to create. Each requires a subnet resource ID and can optionally configure a private DNS zone group, lock, tags, and other endpoint properties. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]?` | No | `null` | Role assignments at the Key Vault scope. Each requires `roleDefinitionIdOrName` and `principalId`; built-in roles can be specified by supported display name, GUID, or full resource ID. |

## Custom parameter types

### Parameter: `networkAcls`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `defaultAction` | `'Allow' \| 'Deny'` | Yes | Action for network traffic that does not match another rule. |
| `bypass` | `'AzureServices' \| 'None'` | No | Whether trusted Azure services can bypass network ACLs. Defaults to `None`. |
| `ipAllowlist` | `string[]` | No | IPv4 addresses or CIDR ranges allowed to access the Key Vault. |
| `subnetIds` | `string[]` | No | Resource IDs of virtual network subnets allowed to access the Key Vault. |

### Parameter: `lock`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `kind` | `'CanNotDelete' \| 'ReadOnly' \| 'None'` | Yes | Lock level. |
| `name` | `string` | No | Lock resource name. If omitted, the module generates a name from the Key Vault name and lock kind. |
| `notes` | `string` | No | Notes to associate with the lock. |

### Parameter: `roleAssignments`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `roleDefinitionIdOrName` | `string` | Yes | Built-in role display name supported by the module, role definition GUID, or full role definition resource ID. |
| `principalId` | `string` | Yes | Object ID of the user, group, service principal, or other supported principal to receive the role. |
| `name` | `string` | No | Role assignment name as a GUID. If omitted, the module generates one. |
| `principalType` | `'ServicePrincipal' \| 'Group' \| 'User' \| 'ForeignGroup' \| 'Device'` | No | Type of the principal. |
| `description` | `string` | No | Description of the role assignment. |
| `condition` | `string` | No | Role assignment condition. |
| `conditionVersion` | `'2.0'` | No | Version of the condition. |
| `delegatedManagedIdentityResourceId` | `string` | No | Resource ID of the delegated managed identity. |

### Parameter: `privateEndpoints`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `subnetResourceId` | `string` | Yes | Resource ID of the subnet where the private endpoint is created. |
| `name` | `string` | No | Private endpoint name. If omitted, the module generates one. |
| `location` | `string` | No | Private endpoint location. If omitted, inferred from the subnet. |
| `privateLinkServiceConnectionName` | `string` | No | Name of the private link service connection. |
| `service` | `string` | No | Private Link subresource. Defaults to `vault` for Key Vault. |
| `resourceGroupResourceId` | `string` | No | Resource group ID in which to create the private endpoint. If omitted, the subnet's resource group is used. |
| [`privateDnsZoneGroup`](#parameter-private-dns-zone-group) | `privateEndpointPrivateDnsZoneGroupType` | No | Private DNS zone group configuration. |
| `isManualConnection` | `bool` | No | Whether to request a manual private link connection. |
| `manualConnectionRequestMessage` | `string` | No | Message for the owner when requesting manual approval (maximum 140 characters). |
| [`customDnsConfigs`](#parameter-custom-dns-configurations) | `privateEndpointCustomDnsConfigType[]` | No | Custom DNS configurations. |
| [`ipConfigurations`](#parameter-private-endpoint-ip-configurations) | `privateEndpointIpConfigurationType[]` | No | Static private endpoint IP configurations. |
| `applicationSecurityGroupResourceIds` | `string[]` | No | Application security group resource IDs for the endpoint IP configuration. |
| `customNetworkInterfaceName` | `string` | No | Custom name for the private endpoint network interface. |
| [`lock`](#parameter-lock) | `lockType` | No | Lock to apply to the private endpoint. Defaults to the Key Vault lock configuration. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]` | No | Role assignments to create for the private endpoint. |
| `tags` | `object` | No | Tags for the private endpoint. Defaults to the Key Vault tags. |

### Parameter: `Private DNS zone group`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `name` | `string` | No | Name of the private DNS zone group. |
| [`privateDnsZoneGroupConfigs`](#parameter-private-dns-zone-group-configurations) | `object[]` | Yes | Private DNS zone configurations to associate with the endpoint (up to five zones). |

### Parameter: `Private DNS zone group configurations`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `privateDnsZoneResourceId` | `string` | Yes | Resource ID of the private DNS zone. |
| `name` | `string` | No | Name of the DNS zone group configuration. |

### Parameter: `Custom DNS configurations`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `fqdn` | `string` | No | Fully qualified domain name that resolves to the private endpoint IP address. |
| `ipAddresses` | `string[]` | Yes | Private IP addresses of the endpoint. |

### Parameter: `Private endpoint IP configurations`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `name` | `string` | Yes | Name unique within the resource group. |
| `properties` | `object` | Yes | Private endpoint IP configuration properties. |
| `properties.groupId` | `string` | Yes | Group ID of the remote service. |
| `properties.memberName` | `string` | Yes | Member name of the remote service group. |
| `properties.privateIPAddress` | `string` | Yes | Private IP address from the endpoint subnet. |

## Outputs

| Name         | Type     | Description |
| :----------- | :------- | :---------- |
| `resourceId` | `string` | The resource ID of the Key Vault. |
| `name`       | `string` | The name of the Key Vault. |
| `uri`        | `string` | The URI of the Key Vault. |

## Examples

To see examples on how to use this module please check [sample-deployments.azcli](./examples/sample-deployments.azcli)
