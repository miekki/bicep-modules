// targetScope = 'subscription'
targetScope = 'resourceGroup'

@description('Name of the environment eg. dev, prod')
param environmentName string = 'dev_1'

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

var varNetworkAcls = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipAllowlist: [ '81.106.66.0/24' ]
  // subnetIds ['']
}

module kv '../modules/security/keyvault/main.bicep' = {
  // scope: rg
  name: 'deploy-kv-test'
  params: {
    location: location
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    tags: tags
    workspaceId: logAnalyticsWorkspace.id
    networkAcls: varNetworkAcls
    principalId: 'c5c1dcd6-c181-466e-a606-cd67d0532eb9' // me

  }
}

module kv_secret '../modules/security/keyvault-secrets/main.bicep' = {
  name: 'deploy-kv-secret-test'
  params: {
    keyVaultName: kv.outputs.name
    secretName: 'ConnectionStrings--DefaultConnection'
    secretValue: 'my pass'
  }
}

module kv_access_policy '../modules/security/keyvault-accesspolicy/main.bicep' = {
  name: 'deploy-kv-access-policy-test'
  params: {
    keyVaultName: kv.outputs.name
    objectId: '47689dc0-8e50-4474-970a-b913a75b5b0e' // for magicsoftware-Calculator-8e88c488-1596-4d79-8d3f-f9d16aa345ad
    secretsPermissions: [ 'get', 'list', 'set', 'delete' ]
  }
}
