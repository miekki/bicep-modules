metadata name = 'Storage Account'
metadata description = 'Deploys an Azure Storage Account with secure defaults, blob containers, network rules, and optional private endpoints.'
metadata owner = 'miekki'

import {
  lockType
  privateEndpointOutputType
  privateEndpointSingleServiceType
  roleAssignmentType
} from '../../common-types/main.bicep'

@description('Required. Name of Storage Account. Must be unique within Azure.')
@maxLength(24)
@minLength(3)
param name string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags of the resource.')
param tags object

@description('Optional. When true, the default SKU is Standard_ZRS instead of Standard_GRS.')
param isZoneRedundant bool = false

@description('Optional. Storage Account SKU. Defaults to Standard_GRS, or Standard_ZRS when isZoneRedundant is true.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param sku string = isZoneRedundant ? 'Standard_ZRS' : 'Standard_GRS'

@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
@description('Optional. Storage Account Kind. Default is StorageV2')
param kind string = 'StorageV2'

@description('''
Optional. The access tier of the storage account, which is used for billing.
Defaults to Premium for BlockBlobStorage and FileStorage accounts, and Hot for other kinds. The supported value depends on the account kind.
''')
@allowed([
  'Cold'
  'Cool'
  'Hot'
  'Premium'
  'Smart'
])
param accessTier string = kind == 'BlockBlobStorage' || kind == 'FileStorage' ? 'Premium' : 'Hot'

@description('Optional. Allow or disallow public access to all blobs or containers in the storage account.')
param allowBlobPublicAccess bool = false

@description('Optional. Properties object for a Blob service of a Storage Account.')
param blobServiceProperties blobServicePropertiesType = {
  containerDeleteRetentionPolicy: {
    allowPermanentDelete: false
    days: 90
    enabled: true
  }
  deleteRetentionPolicy: {
    allowPermanentDelete: false
    days: 90
    enabled: true
  }
}

@description('Optional. Array of blob containers to be created for blobServices of Storage Account.')
param blobContainers blobContainerType[] = []

@description('Optional. Configuration for network access rules.')
param networkAcls networkAclsType = {
  defaultAction: 'Deny'
}

@description('Optional. Controls public network access. When omitted, it is disabled when private endpoints are configured and enabled otherwise. Network ACLs still apply.')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string?

@description('Optional. Management lock for the Key Vault. Use CanNotDelete or ReadOnly to apply a lock; omit it or use None for no lock.')
param lock lockType?

@description('Optional. Private endpoints to create for the Storage Account. Each endpoint requires a subnet resource ID. The service defaults to blob and can be set to another supported Storage subresource.')
param privateEndpoints privateEndpointSingleServiceType[]?

@description('Optional. Role assignments to create at the Key Vault scope. Supply a supported built-in role name, role definition GUID, or full role definition resource ID.')
param roleAssignments roleAssignmentType[]?

// **********************************
// variables
// **********************************

var varNetworkAclsIpRules = [for ip in networkAcls.?ipAllowlist ?? []: { action: 'Allow', value: ip }]

var varNetworkAclsVirtualNetworkRules = [for subnet in networkAcls.?subnetIds ?? []: { action: 'Allow', id: subnet }]

var varNetworkAcls = {
  bypass: networkAcls.?bypass ?? 'AzureServices'
  defaultAction: networkAcls.defaultAction
  ipRules: varNetworkAclsIpRules
  resourceAccessRules: networkAcls.?resourceAccessRules
  virtualNetworkRules: varNetworkAclsVirtualNetworkRules
}

var effectivePublicNetworkAccess = !empty(publicNetworkAccess)
  ? publicNetworkAccess
  : (!empty(privateEndpoints) ? 'Disabled' : 'Enabled')

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Reader and Data Access': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'c12c1c16-33a1-487b-954d-41c89c60f349'
  )
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'Storage Account Backup Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1'
  )
  'Storage Account Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  )
  'Storage Account Key Operator Service Role': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '81a9662b-bebf-436f-a333-f67b29880f12'
  )
  'Storage Blob Data Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  )
  'Storage Blob Data Owner': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  )
  'Storage Blob Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  )
  'Storage Blob Delegator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'db58b8e5-c6ad-4a2a-8342-4190687cbf4a'
  )
  'Storage File Data Privileged Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '69566ab7-960f-475b-8e7c-b3118f30c6bd'
  )
  'Storage File Data Privileged Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b8eda974-7b85-4f76-af95-65846b26df6d'
  )
  'Storage File Data SMB Share Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
  )
  'Storage File Data SMB Share Elevated Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'a7264617-510b-434b-a828-9731dc254ea7'
  )
  'Storage File Data SMB Share Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'aba4ae5f-2193-4029-9191-0cb91df5e314'
  )
  'Storage Queue Data Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
  )
  'Storage Queue Data Message Processor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '8a0f0c08-91a1-4084-bc3d-661d67233fed'
  )
  'Storage Queue Data Message Sender': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
  )
  'Storage Queue Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '19e7f393-937e-4f77-808e-94535e297925'
  )
  'Storage Table Data Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  )
  'Storage Table Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '76199698-9eea-4c19-bc75-cec21354c6b6'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// **********************************
// Resources
// **********************************

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-09-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: kind
  tags: tags
  properties: {
    accessTier: accessTier
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: allowBlobPublicAccess
    networkAcls: varNetworkAcls
    allowSharedKeyAccess: false
    publicNetworkAccess: effectivePublicNetworkAccess
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2026-09-01' = {
  name: 'default'
  parent: storageAccount
  properties: blobServiceProperties
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-09-01' = [
  for container in blobContainers: {
    name: container.name
    parent: blobService
    properties: container.?properties ?? {}
  }
]

module storageAccount_privateEndpoints '../../network/internal-modules/private-endpoint/main.bicep' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(storageAccount.id, deployment().name)}-storage-private-endpoint-${index}'
    scope: resourceGroup(
      split(privateEndpoint.?resourceGroupResourceId ?? privateEndpoint.subnetResourceId, '/')[2],
      split(privateEndpoint.?resourceGroupResourceId ?? privateEndpoint.subnetResourceId, '/')[4]
    )
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(storageAccount.id, '/'))}-${privateEndpoint.?service ?? 'blob'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(storageAccount.id, '/'))}-${privateEndpoint.?service ?? 'blob'}-${index}'
              properties: {
                privateLinkServiceId: storageAccount.id
                groupIds: [
                  privateEndpoint.?service ?? 'blob'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(storageAccount.id, '/'))}-${privateEndpoint.?service ?? 'blob'}-${index}'
              properties: {
                privateLinkServiceId: storageAccount.id
                groupIds: [
                  privateEndpoint.?service ?? 'blob'
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2020-06-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock
      privateDnsZoneGroup: privateEndpoint.?privateDnsZoneGroup
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? tags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
      privateDnsZoneName: privateEndpoint.?privateDnsZoneName
      privateDnsARecordName: !empty(privateEndpoint.?privateDnsZoneName) ? storageAccount.name : null
      numberOfIps: 1
      privateDnsZoneId: privateEndpoint.?privateDnsZoneId
    }
  }
]

var storageAccountLockName = lock.?name ?? '${name}-${lock.?kind ?? 'lock'}-lock'

var storageAccountLockProperties = {
  level: lock.?kind ?? 'None'
  notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
    ? 'Cannot delete resource or child resources.'
    : 'Cannot delete or modify the resource or child resources.')
}

var storageAccountLockEnabled = lock.?kind != null && lock.?kind != 'None'

resource storageAccount_lock 'Microsoft.Authorization/locks@2020-05-01' = if (storageAccountLockEnabled) {
  name: storageAccountLockName
  properties: storageAccountLockProperties
  scope: storageAccount
}

resource storageAccount_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(storageAccount.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: storageAccount
  }
]
// **********************************
// Outputs
// **********************************

@description('The ID of the Storage Account. Use this ID to reference the Storage Account in other Azure resource deployments.')
output resourceId string = storageAccount.id

@description('The name of the Storage Account resource')
output name string = storageAccount.name

@description('The private endpoints created for the Storage Account.')
output privateEndpoints privateEndpointOutputType[] = [
  for (item, index) in (privateEndpoints ?? []): {
    name: storageAccount_privateEndpoints[index].outputs.name
    resourceId: storageAccount_privateEndpoints[index].outputs.resourceId
    groupId: storageAccount_privateEndpoints[index].outputs.?groupId!
    customDnsConfigs: storageAccount_privateEndpoints[index].outputs.customDnsConfigs
    networkInterfaceResourceIds: storageAccount_privateEndpoints[index].outputs.networkInterfaceResourceIds
  }
]

// **********************************
// Types
// **********************************

@description('The properties of a storage accounts Blob service.')
type blobServicePropertiesType = {
  changeFeed: changeFeed?
  containerDeleteRetentionPolicy: deleteRetentionPolicyType?
  cors: cors?
  deleteRetentionPolicy: deleteRetentionPolicyType?
  isVersioningEnabled: bool?
  lastAccessTimeTrackingPolicy: lastAccessTimeTrackingPolicyType?
  restorePolicy: restorePolicy?
}

@description('The blob service properties for change feed events.')
type changeFeed = {
  enabled: bool
  @minValue(1)
  @maxValue(146000)
  @description('Indicates the duration of changeFeed retention in days. A null value indicates an infinite retention of the change feed.')
  retentionInDays: int?
}

type deleteRetentionPolicyType = {
  @description('This property when set to true allows deletion of the soft deleted blob versions and snapshots. This property cannot be used blob restore policy. This property only applies to blob service and does not apply to containers or file share.')
  allowPermanentDelete: bool
  @minValue(1)
  @maxValue(365)
  @description('Indicates the number of days that the deleted item should be retained.')
  days: int
  enabled: bool
}

@description('Specifies CORS rules for the Blob service. You can include up to five CorsRule elements in the request. If no CorsRule elements are included in the request body, all CORS rules will be deleted, and CORS will be disabled for the Blob service.')
type cors = {
  corsRules: {
    @description('A list of headers allowed to be part of the cross-origin request.')
    allowedHeaders: string[]
    @description('A list of HTTP methods that are allowed to be executed by the origin.')
    allowedMethods: ('DELETE' | 'GET' | 'HEAD' | 'MERGE' | 'OPTIONS' | 'PATCH' | 'POST' | 'PUT')[]
    @description('A list of origin domains that will be allowed via CORS, or "*" to allow all domains')
    allowedOrigins: string[]
    @description('A list of response headers to expose to CORS clients.')
    exposedHeaders: string[]
    @description('The number of seconds that the client/browser should cache a preflight response.')
    maxAgeInSeconds: int
  }[]
}

@description('The blob service property to configure last access time based tracking policy.')
type lastAccessTimeTrackingPolicyType = {
  blobType: string[]?
  enable: bool
}

@description('The blob service property to configure last access time based tracking policy.')
type restorePolicy = {
  @description('how long this blob can be restored. It should be great than zero and less than DeleteRetentionPolicy.days.')
  days: int?
  enabled: bool
}

type blobContainerType = {
  @minLength(3)
  @maxLength(63)
  name: string
  properties: blobContainerPropertiesType?
}

type blobContainerPropertiesType = {
  defaultEncryptionScope: string?
  denyEncryptionScopeOverride: bool?
  publicAccess: ('Blob' | 'Container' | 'None')?
}

type networkAclsType = {
  @description('Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.')
  bypass: ('AzureServices' | 'Logging' | 'Metrics' | 'None')?
  @description('Specifies whether all network access is allowed or denied when no other rules match.')
  defaultAction: ('Allow' | 'Deny')
  @description('Specifies the IP or IP range in CIDR format to be allowed to connect. Only IPV4 address is allowed.')
  ipAllowlist: string[]?
  @description('Sets the resource access rules.')
  resourceAccessRules: networkAclsResourceAccessRuleType[]?
  @description('Sets the virtual network rules.')
  subnetIds: string[]?
}

type networkAclsResourceAccessRuleType = {
  @description('Specifies the resource id of the resource to which the access rule applies.')
  resourceId: string
  @description('Specifies the tenant id of the resource to which the access rule applies.')
  tenantId: string
}
