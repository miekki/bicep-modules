// targetScope = 'subscription'
targetScope = 'resourceGroup'

@description('Name of the environment eg. dev, prod')
param environmentName string = 'dev'

@description('Location for all resources')
param location string = 'uksouth'

var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { environment: environmentName }

module appConfig '../modules/config/app-configuration/main.bicep' = {
  name: 'deploy-app-config-test'
  params: {
    location: location
    name: '${abbrs.appConfigurationConfigurationStores}${resourceToken}'
    tags: tags
    roleAssignments: [
      {
        principalId: 'c5c1dcd6-c181-466e-a606-cd67d0532eb9'
        roleDefinitionIdOrName: 'App Configuration Data Owner'
      }
    ]
  }
}
