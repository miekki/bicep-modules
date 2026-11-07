targetScope = 'subscription'

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

module storageAccount '../../main.bicep' = {
  name: 'storageAccountRequiredParameters'
  scope: resourceGroup
  params: {
    name: replace(storageAccountName, '-', '')
    location: location
    tags: tags
  }
}
