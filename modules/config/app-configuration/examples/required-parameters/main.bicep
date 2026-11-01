targetScope = 'subscription'

param uniqueStr string = substring(uniqueString(subscription().id, utcNow()), 1, 3)

var companyName = 'mm'
var projectName = 'test-bicep'
var environmentName = 'dev'
var name = '${companyName}-${projectName}-${environmentName}'
var tags = { environment: environmentName }
var storeName = '${name}-${uniqueStr}-${abbrs.appConfigurationConfigurationStores}'

#disable-next-line no-hardcoded-location
var location string = 'uksouth'
var abbrs = loadJsonContent('../../../../abbreviations.json')

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: '${name}-${abbrs.resourcesResourceGroups}'
  location: location
  tags: tags
}

module appConfiguration '../../main.bicep' = {
  name: 'appConfigurationRequiredParameters'
  scope: rg
  params: {
    name: storeName
    location: location
    tags: tags
  }
}
