metadata name = 'Storage Account'
metadata description = 'This module deploy storage account'
metadata owner = 'MM'

@description('Required. Name of Storage Account. Must be unique within Azure.')
@maxLength(24)
@minLength(3)
param name string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags of the resource.')
param tags object

@description('Optional. This toggle changes the default value of the sku parameter from Standard_LRS to Standard_ZRS.')
param isZoneRedundant bool = false

@description('Optional. Storage Account SKU. default is Standard_LRS')
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
Required for storage accounts where kind = BlobStorage. The 'Premium' access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.
Default is Hot.
''')
@allowed([
  'Cool'
  'Hot'
])
param accessTier string = 'Hot'

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

var varNetworkAclsIpRules = [for ip in networkAcls.?ipAllowlist ?? []: { action: 'Allow', value: ip }]

var varNetworkAclsVirtualNetworkRules = [for subnet in networkAcls.?subnetIds ?? []: { action: 'Allow', id: subnet }]

var varNetworkAcls = {
  bypass: networkAcls.?bypass ?? 'AzureServices'
  defaultAction: networkAcls.defaultAction
  ipRules: varNetworkAclsIpRules
  resourceAccessRules: networkAcls.?resourceAccessRules
  virtualNetworkRules: varNetworkAclsVirtualNetworkRules
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
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
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: blobServiceProperties
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for container in blobContainers: {
  name: container.name
  parent: blobService
  properties: container.?properties ?? {}
}]

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
  resourceAccessRuleId: string
  @description('Specifies the tenant id of the resource to which the access rule applies.')
  tenantId: string
}

@description('The name of the Storage Account resource')
output name string = storageAccount.name

@description('The ID of the Storage Account. Use this ID to reference the Storage Account in other Azure resource deployments.')
output resourceId string = storageAccount.id
