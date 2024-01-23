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
param sku string = isZoneRedundant ? 'Standard_ZRS' : 'Standard_LRS'

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
  }
}

@description('The name of the Storage Account resource')
output name string = name

@description('The ID of the Storage Account. Use this ID to reference the Storage Account in other Azure resource deployments.')
output id string = storageAccount.id
