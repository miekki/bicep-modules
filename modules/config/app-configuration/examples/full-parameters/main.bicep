targetScope = 'subscription'

@description('The resource group to contain the App Configuration store.')
param resourceGroupName string = 'rg-appconfiguration-samples'

@description('The Azure region for the resource group and store.')
param location string = 'uksouth'

@description('The resource ID of an existing Log Analytics workspace.')
param workspaceId string

var tags = {
  environment: 'sample'
  owner: 'platform'
}

var storeName = 'appconfig-${uniqueString(subscription().id)}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module appConfiguration '../../main.bicep' = {
  name: 'appConfigurationFullParameters'
  scope: resourceGroup
  params: {
    name: storeName
    location: location
    tags: tags
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: []
    }
    sku: 'Standard'
    createMode: 'Default'
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
    softDeleteRetentionInDays: 7
    keyValues: []
    replicaLocations: [
      {
        name: 'secondary'
        replicaLocation: 'westeurope'
      }
    ]
    diagnosticSettings: {
      workspaceId: workspaceId
      logs: [
        {
          categoryGroup: 'audit'
          enabled: true
        }
      ]
    }
    lock: {
      kind: 'None'
    }
    roleAssignments: []
    dataPlaneProxy: {
      authenticationMode: 'Pass-through'
      privateLinkDelegation: 'Disabled'
    }
    privateEndpoints: []
  }
}
