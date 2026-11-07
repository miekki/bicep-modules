targetScope = 'subscription'

param uniqueStr string = substring(uniqueString(subscription().id, utcNow()), 1, 3)

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

module kv '../../../../../modules/security/keyvault/main.bicep' = {
  name: 'kv'
  scope: rg
  params: {
    name: kv_name
    location: location
    tags: tags
    secrets: [
      {
        name: 'My Secret 1'
        value: 'My Secret value 1'
        tags: tags
      }
      {
        name: 'My Secret 2'
        value: 'My Secret value 2'
        tags: tags
        attributes: {
          enabled: true
          exp: secretsExpiryDate
        }
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets Officer'
        principalId: 'c5c1dcd6-c181-466e-a606-cd67d0532eb9'
      }
    ]
  }
}

// Add additional secrets to the existsing key vault
module kv_secrets '../../../../../modules/security/keyvault-secrets/main.bicep' = {
  scope: rg
  params: {
    name: 'Test-Secret'
    keyVaultName: kv.outputs.name
    value: 'This is secret value'
  }
}
