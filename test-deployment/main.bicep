// targetScope = 'subscription'
targetScope = 'resourceGroup'

@description('Name of the environment eg. dev, prod')
param environmentName string = 'dev'

@description('Location for all resources')
param location string = 'uksouth'

var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { environment: environmentName }

// resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
//   name: 'bicep-module-tmp-test-rg'
// }

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  // scope: rg
  name: take('log-${uniqueString(resourceGroup().id, subscription().id)}', 63)
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

module kv '../modules/security/keyvault/main.bicep' = {
  // scope: rg
  name: 'deploy-kv-test'
  params: {
    location: location
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    tags: tags
    workspaceId: logAnalyticsWorkspace.id
    networkAcls: {
      defaultAction: 'Allow'
    }
    rbacPolicies: [ 'c5c1dcd6-c181-466e-a606-cd67d0532eb9' ]
  }
}
