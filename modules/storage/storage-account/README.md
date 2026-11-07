# Storage Account

This module deploys an Azure Storage Account, its Blob service, and optional
Blob containers. It applies secure defaults, supports Storage network ACLs, and
can create private endpoints for Storage subresources.

## Details

- Storage account names must be globally unique, 3-24 characters long, and use
  lowercase letters and numbers.
- Shared Key authorization is disabled and public Blob access is disabled by
  default.
- Network ACLs deny unmatched traffic by default. The trusted Azure services
  bypass is enabled by default.
- Public network access is disabled automatically when private endpoints are
  configured. Set `publicNetworkAccess` to override this behavior.
- Private endpoints support the Storage group IDs `blob`, `blob_secondary`,
  `file`, `file_secondary`, `queue`, `queue_secondary`, `table`,
  `table_secondary`, `web`, `web_secondary`, `dfs`, and `dfs_secondary`.
  Configure private DNS using `privateDnsZoneGroup` or the supported DNS zone
  parameters on each endpoint. Storage private DNS zones depend on the selected
  service; for example, Blob uses `privatelink.blob.core.windows.net`.
- Configure data-plane access with Azure RBAC and Microsoft Entra ID because
  Shared Key access is disabled.
- An optional management lock can protect the Storage Account from deletion or
  modification. Optional role assignments grant Azure RBAC permissions at the
  Storage Account scope.

## Parameters

| Name | Type | Required | Default | Description |
| :--- | :---: | :---: | :--- | :--- |
| `name` | `string` | Yes | — | Globally unique Storage Account name; 3-24 lowercase letters and numbers. |
| `location` | `string` | Yes | — | Azure region for the Storage Account. Private endpoints use their subnet's region unless an endpoint location is specified. |
| `tags` | `object` | Yes | — | Tags applied to the Storage Account and, unless overridden, its private endpoints. |
| `isZoneRedundant` | `bool` | No | `false` | Selects `Standard_ZRS` as the default SKU when true; otherwise the default SKU is `Standard_GRS`. An explicit `sku` takes precedence. |
| `sku` | `string` | No | `Standard_GRS` or `Standard_ZRS` when `isZoneRedundant` is true | Storage Account SKU. |
| `kind` | `string` | No | `StorageV2` | Storage Account kind: `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage`, or `StorageV2`. |
| `accessTier` | `string` | No | `Premium` for `BlockBlobStorage` and `FileStorage`; otherwise `Hot` | Account access tier: `Cold`, `Cool`, `Hot`, `Premium`, or `Smart`. Supported values depend on `kind`. |
| `allowBlobPublicAccess` | `bool` | No | `false` | Controls whether containers and blobs can allow anonymous public access. |
| [`blobServiceProperties`](#parameter-blobserviceproperties) | `blobServicePropertiesType` | No | Enabled 90-day Blob and container soft-delete policies | Blob service settings, including retention, versioning, change feed, CORS, and restore policy. |
| [`blobContainers`](#parameter-blobcontainers) | `blobContainerType[]` | No | `[]` | Blob containers to create. Each item requires a `name` and can include container properties. |
| [`networkAcls`](#parameter-networkacls) | `networkAclsType` | No | `defaultAction: 'Deny'`; `bypass: 'AzureServices'` | Network rules: `defaultAction`, `bypass`, `ipAllowlist`, `subnetIds`, and `resourceAccessRules`. |
| `publicNetworkAccess` | `string?` | No | `null` | Set to `Enabled`, `Disabled`, or `SecuredByPerimeter`. When omitted, public access is disabled if private endpoints are configured and enabled otherwise. Network ACLs still apply when public network access is enabled. |
| [`privateEndpoints`](#parameter-privateendpoints) | `privateEndpointSingleServiceType[]?` | No | `null` | Private endpoints to create. Each requires `subnetResourceId`; `service` defaults to `blob`. Items also support endpoint naming/location, private DNS configuration, manual approval, tags, locks, role assignments, and network interface options. |
| [`lock`](#parameter-lock) | `lockType?` | No | `null` | Optional management lock for the Storage Account. Use `CanNotDelete` or `ReadOnly`; `None` or omission creates no lock. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]?` | No | `null` | Optional Azure RBAC assignments to create at the Storage Account scope. |

## Custom parameter types

### Parameter: `blobServiceProperties`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| [`changeFeed`](#parameter-changefeed) | `changeFeed?` | No | Change feed configuration. |
| [`containerDeleteRetentionPolicy`](#parameter-deleteretentionpolicytype) | `deleteRetentionPolicyType?` | No | Soft-delete policy for deleted containers. |
| [`cors`](#parameter-cors) | `cors?` | No | Cross-origin resource sharing rules for the Blob service. |
| [`deleteRetentionPolicy`](#parameter-deleteretentionpolicytype) | `deleteRetentionPolicyType?` | No | Soft-delete policy for deleted blobs and snapshots. |
| `isVersioningEnabled` | `bool?` | No | Whether Blob versioning is enabled. |
| [`lastAccessTimeTrackingPolicy`](#parameter-lastaccesstimetrackingpolicytype) | `lastAccessTimeTrackingPolicyType?` | No | Configuration for tracking blob last-access time. |
| [`restorePolicy`](#parameter-restorepolicy) | `restorePolicy?` | No | Point-in-time restore policy. |

### Parameter: `changeFeed`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `enabled` | `bool` | Yes | Whether change feed is enabled. |
| `retentionInDays` | `int?` | No | Retention duration in days (1–146,000). Omit for infinite retention. |

### Parameter: `deleteRetentionPolicyType`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `allowPermanentDelete` | `bool` | Yes | Whether permanent deletion of soft-deleted blobs or snapshots is allowed. This setting does not apply to container soft delete. |
| `days` | `int` | Yes | Number of retention days (1–365). |
| `enabled` | `bool` | Yes | Whether soft delete is enabled. |

### Parameter: `cors`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `corsRules` | `object[]` | Yes | Up to five CORS rules. Each rule has the following required properties. |
| `allowedHeaders` | `string[]` | Yes | Request headers allowed by CORS. |
| `allowedMethods` | `('DELETE' \| 'GET' \| 'HEAD' \| 'MERGE' \| 'OPTIONS' \| 'PATCH' \| 'POST' \| 'PUT')[]` | Yes | HTTP methods allowed by CORS. |
| `allowedOrigins` | `string[]` | Yes | Allowed origin domains; `*` allows all origins. |
| `exposedHeaders` | `string[]` | Yes | Response headers exposed to the browser. |
| `maxAgeInSeconds` | `int` | Yes | How long, in seconds, the browser may cache a preflight response. |

### Parameter: `lastAccessTimeTrackingPolicyType`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `blobType` | `string[]?` | No | Blob types for which last access time is tracked. |
| `enable` | `bool` | Yes | Whether last access time tracking is enabled. |

### Parameter: `restorePolicy`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `days` | `int?` | No | Number of days that blobs can be restored. Must be greater than zero and less than the blob delete-retention period. |
| `enabled` | `bool` | Yes | Whether point-in-time restore is enabled. |

### Parameter: `blobContainers`

Type: `blobContainerType`.

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `name` | `string` | Yes | Container name (3–63 characters). |
| [`properties`](#parameter-blobcontainerpropertiestype) | `blobContainerPropertiesType?` | No | Optional container settings. |

### Parameter: `blobContainerPropertiesType`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `defaultEncryptionScope` | `string?` | No | Default encryption scope for blobs in the container. |
| `denyEncryptionScopeOverride` | `bool?` | No | Whether clients are prevented from overriding the default encryption scope. |
| `publicAccess` | `('Blob' \| 'Container' \| 'None')?` | No | Anonymous access level for the container. The account-level `allowBlobPublicAccess` setting must also permit public access. |

### Parameter: `networkAcls`

Type: `networkAclsType`.

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `defaultAction` | `'Allow' \| 'Deny'` | Yes | Action for network traffic that does not match another rule. |
| `bypass` | `('AzureServices' \| 'Logging' \| 'Metrics' \| 'None')?` | No | Services that can bypass network ACLs. Defaults to `AzureServices`. |
| `ipAllowlist` | `string[]?` | No | IPv4 addresses or CIDR ranges allowed to access the Storage Account. |
| `subnetIds` | `string[]?` | No | Resource IDs of virtual network subnets allowed to access the Storage Account. |
| [`resourceAccessRules`](#parameter-networkaclsresourceaccessruletype) | `networkAclsResourceAccessRuleType[]?` | No | Resource-instance network rules. |

### Parameter: `networkAclsResourceAccessRuleType`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `resourceId` | `string` | Yes | Resource ID of the trusted resource. |
| `tenantId` | `string` | Yes | Tenant ID of the trusted resource. |

### Parameter: `privateEndpoints`

Type: `privateEndpointSingleServiceType`.

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `subnetResourceId` | `string` | Yes | Resource ID of the subnet where the endpoint is created. |
| `name` | `string?` | No | Private endpoint name. If omitted, the module generates one. |
| `location` | `string?` | No | Endpoint region. If omitted, it is inferred from the subnet. |
| `service` | `string?` | No | Storage Private Link subresource/group ID, such as `blob`, `file`, `queue`, `table`, `web`, or `dfs`. Defaults to `blob`. |
| `privateLinkServiceConnectionName` | `string?` | No | Name of the private link service connection. |
| `resourceGroupResourceId` | `string?` | No | Resource group ID where the endpoint is deployed. If omitted, the subnet's resource group is used. |
| [`privateDnsZoneGroup`](#parameter-private-dns-zone-group) | `privateEndpointPrivateDnsZoneGroupType?` | No | Private DNS zone group configuration. |
| `isManualConnection` | `bool?` | No | Whether the private link connection requires manual approval. |
| `manualConnectionRequestMessage` | `string?` | No | Message for the resource owner when requesting manual approval (maximum 140 characters). |
| [`customDnsConfigs`](#parameter-custom-dns-configurations) | `privateEndpointCustomDnsConfigType[]?` | No | Custom DNS configurations. |
| [`ipConfigurations`](#parameter-private-endpoint-ip-configurations) | `privateEndpointIpConfigurationType[]?` | No | Static IP configurations for the endpoint. |
| `applicationSecurityGroupResourceIds` | `string[]?` | No | Application security group resource IDs for endpoint IP configurations. |
| `customNetworkInterfaceName` | `string?` | No | Custom name for the endpoint's network interface. |
| [`lock`](#parameter-locktype-private-endpoint-lock) | `lockType?` | No | Management lock to apply to the endpoint. |
| [`roleAssignments`](#parameter-roleassignmenttype-private-endpoint-role-assignments) | `roleAssignmentType[]?` | No | Role assignments to create at the endpoint scope. |
| `tags` | `object?` | No | Endpoint tags. Defaults to the Storage Account tags. |
| `privateDnsZoneName` | `string?` | No | Private DNS zone name used to create an A record. |
| `privateDnsZoneId` | `string?` | No | Private DNS zone resource ID, including when the zone is in another resource group. |

### Parameter: `lock`

Type: `lockType`, shared from [`modules/common-types/main.bicep`](../../common-types/main.bicep).

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `kind` | `'CanNotDelete' \| 'ReadOnly' \| 'None'` | Yes | Lock level. Use `None` for no lock. |
| `name` | `string?` | No | Lock resource name. If omitted, one is generated. |
| `notes` | `string?` | No | Notes to associate with the lock. |

### Parameter: `roleAssignments`

Each item uses the shared `roleAssignmentType` from
[`modules/common-types/main.bicep`](../../common-types/main.bicep).
Role names may be a supported built-in role display name, role-definition GUID,
or full role-definition resource ID.

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `roleDefinitionIdOrName` | `string` | Yes | Role display name, role-definition GUID, or full role-definition resource ID. |
| `principalId` | `string` | Yes | Object ID of the user, group, service principal, or other supported principal. |
| `name` | `string?` | No | Role-assignment name as a GUID. If omitted, one is generated. |
| `principalType` | `('ServicePrincipal' \| 'Group' \| 'User' \| 'ForeignGroup' \| 'Device')?` | No | Type of the principal. |
| `description` | `string?` | No | Description of the role assignment. |
| `condition` | `string?` | No | Condition that limits the assignment. |
| `conditionVersion` | `'2.0'?` | No | Condition version; used only when `condition` is set. |
| `delegatedManagedIdentityResourceId` | `string?` | No | Resource ID of the delegated managed identity. |

### Parameter: `Private DNS zone group`

Type: [`privateEndpointPrivateDnsZoneGroupType`](#parameter-private-dns-zone-group).

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `name` | `string?` | No | Name of the private DNS zone group. |
| [`privateDnsZoneGroupConfigs`](#parameter-private-dns-zone-group-configurations) | `object[]` | Yes | DNS zone configurations to associate with the endpoint (up to five zones). |

### Parameter: `Private DNS zone group configurations`

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `privateDnsZoneResourceId` | `string` | Yes | Resource ID of the private DNS zone. |
| `name` | `string?` | No | Name of the DNS zone configuration. |

### Parameter: `Custom DNS configurations`

Type: [`privateEndpointCustomDnsConfigType`](#parameter-custom-dns-configurations).

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `fqdn` | `string?` | No | Fully qualified domain name that resolves to the endpoint IP address. |
| `ipAddresses` | `string[]` | Yes | Private IP addresses for the endpoint. |

### Parameter: `Private endpoint IP configurations`

Type: [`privateEndpointIpConfigurationType`](#parameter-private-endpoint-ip-configurations).

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `name` | `string` | Yes | Name unique within the resource group. |
| `properties` | `object` | Yes | Configuration of the private endpoint IP. |
| `properties.groupId` | `string` | Yes | Group ID of the remote service. |
| `properties.memberName` | `string` | Yes | Member name of the remote service group. |
| `properties.privateIPAddress` | `string` | Yes | Static private IP address from the endpoint subnet. |

### Parameter: `lockType` (also used for the Storage Account lock)

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `kind` | `'CanNotDelete' \| 'ReadOnly' \| 'None'` | Yes | Lock level. |
| `name` | `string?` | No | Lock resource name. If omitted, one is generated. |
| `notes` | `string?` | No | Notes to associate with the lock. |

### Parameter: `roleAssignmentType` (also used for Storage Account role assignments)

| Name | Type | Required | Description |
| :--- | :--- | :------: | :---------- |
| `roleDefinitionIdOrName` | `string` | Yes | Role display name, role definition GUID, or full role definition resource ID. |
| `principalId` | `string` | Yes | Object ID of the user, group, service principal, or other supported principal. |
| `name` | `string?` | No | Role assignment name as a GUID. If omitted, one is generated. |
| `principalType` | `('ServicePrincipal' \| 'Group' \| 'User' \| 'ForeignGroup' \| 'Device')?` | No | Type of the principal. |
| `description` | `string?` | No | Description of the role assignment. |
| `condition` | `string?` | No | Role assignment condition. |
| `conditionVersion` | `'2.0'?` | No | Condition version. |
| `delegatedManagedIdentityResourceId` | `string?` | No | Resource ID of the delegated managed identity. |



## Outputs

| Name | Type | Description |
| :--- | :---: | :--- |
| `name` | `string` | Storage Account name. |
| `resourceId` | `string` | Storage Account resource ID. |
| [`privateEndpoints`](#output-parameter-privateendpointoutputtype) | `privateEndpointOutputType[]` | Created private endpoints, including resource IDs, group IDs, DNS configurations, and network interface IDs. |

### Output parameter: `privateEndpointOutputType`

| Name | Type | Description |
| :--- | :--- | :---------- |
| `name` | `string` | Name of the private endpoint. |
| `resourceId` | `string` | Resource ID of the private endpoint. |
| `groupId` | `string?` | Private Link group ID. |
| `customDnsConfigs` | `object[]` | DNS configuration entries; each has an optional `fqdn` and required `ipAddresses` (`string[]`). |
| `networkInterfaceResourceIds` | `string[]` | Resource IDs of the endpoint network interfaces. |

## Examples

Both examples target the subscription scope and create a dedicated resource
group for their resources. Use the [sample deployment commands](./examples/sample-deployments.azcli)
to deploy them:

- [Required parameters](./examples/required-parameters/main.bicep)
- [Full parameters, including a management lock, role assignment, and private endpoint](./examples/full-parameters/main.bicep) (requires the object ID of an existing principal for the role assignment)
