targetScope = 'subscription'

param uniqueStr string = substring(uniqueString(subscription().id, utcNow()), 1, 2)

var companyName = 'mm'
var projectName = 'test-bicep'
var environmentName = 'dev'
var name = '${companyName}-${projectName}-${environmentName}'
var tags = { environment: environmentName }
var kv_name = '${name}-${uniqueStr}-${abbrs.keyVaultVaults}'

#disable-next-line no-hardcoded-location
var location = 'uksouth'
var abbrs = loadJsonContent('../../../../abbreviations.json')

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: '${name}-${abbrs.resourcesResourceGroups}'
  location: location
  tags: tags
}

param baseTime string = utcNow('u')
var secretsExpiryDate = dateTimeToEpoch(dateTimeAdd(baseTime, 'P1Y'))
// secret will be available after this date
var secretsNotBeforeDate = dateTimeToEpoch(dateTimeAdd(baseTime, 'P1M'))

module kv '../../../../../modules/security/keyvault/main.bicep' = {
  name: 'kv'
  scope: rg
  params: {
    name: kv_name
    location: location
    tags: tags
  }
}

module kv_secret '../../main.bicep' = {
  scope: rg
  name: '${uniqueString(deployment().name, 'uksouth')}-secret'
  params: {
    keyVaultName: kv.outputs.name
    name: 'My Secret'
    value: 'My Secret value'
    tags: tags
    enabled: true
    expiryDateInSeconds: secretsExpiryDate
    notBeforeDateInSecounds: secretsNotBeforeDate
  }
}
