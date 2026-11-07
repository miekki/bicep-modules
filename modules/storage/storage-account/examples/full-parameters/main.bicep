targetScope = 'subscription'

@description('Object ID of an existing user, group, or service principal to grant Storage Blob Data Reader.')
param roleAssignmentPrincipalId string

param uniqueStr string = substring(uniqueString(subscription().id, deployment().name), 1, 3)

var companyName = 'mm'
var projectName = 'test-bicep'
var environmentName = 'dev'
var name = '${companyName}-${projectName}-${environmentName}'
var tags = { environment: environmentName }
var storageAccountName = '${name}${uniqueStr}${abbrs.storageStorageAccounts}'

#disable-next-line no-hardcoded-location
var location string = 'uksouth'
var abbrs = loadJsonContent('../../../../abbreviations.json')

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: '${name}-${abbrs.resourcesResourceGroups}'
  location: location
  tags: tags
}

module virtualNetwork '../../../../network/virtual-network/main.bicep' = {
  name: 'storagePrivateEndpointsVnet'
  scope: resourceGroup
  params: {
    name: '${name}-${abbrs.networkVirtualNetworks}'
    location: location
    tags: tags
    addressPrefixes: [
      '10.20.0.0/16'
    ]
    subnets: [
      {
        name: 'private-endpoints'
        addressPrefix: '10.20.1.0/24'
      }
    ]
  }
}

module blobPrivateDnsZone '../../../../network/private-dns-zone/main.bicep' = {
  name: 'storageBlobPrivateDnsZone'
  scope: resourceGroup
  params: {
    #disable-next-line no-hardcoded-env-urls
    name: 'privatelink.blob.core.windows.net'
    location: 'global'
    tags: tags
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
        registrationEnabled: false
      }
    ]
  }
}

module storageAccount '../../main.bicep' = {
  name: 'storageAccountFullParameters'
  scope: resourceGroup
  params: {
    name: replace(storageAccountName, '-', '')
    location: location
    tags: tags
    isZoneRedundant: true
    sku: 'Standard_ZRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    blobServiceProperties: {
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        days: 30
        enabled: true
      }
      isVersioningEnabled: true
    }
    blobContainers: [
      {
        name: 'application-data'
        properties: {
          publicAccess: 'None'
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'
      ipAllowlist: []
      subnetIds: []
      resourceAccessRules: []
    }
    publicNetworkAccess: 'Disabled'
    lock: {
      kind: 'CanNotDelete'
      notes: 'Protect the sample Storage Account from accidental deletion.'
    }
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Storage Blob Data Reader'
        principalId: roleAssignmentPrincipalId
      }
    ]
    privateEndpoints: [
      {
        service: 'blob'
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              name: 'blob'
              privateDnsZoneResourceId: blobPrivateDnsZone.outputs.resourceId
            }
          ]
        }
      }
    ]
  }
}
