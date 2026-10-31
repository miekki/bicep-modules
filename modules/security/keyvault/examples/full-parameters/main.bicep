targetScope = 'subscription'

param uniqueStr string = substring(uniqueString(subscription().id, utcNow()), 1, 2)

var companyName = 'mm'
var projectName = 'test-bicep'
var environmentName = 'dev'
var name = '${companyName}-${projectName}-${environmentName}'
var vnet_name = '${companyName}-${projectName}-${environmentName}-vnet'
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

resource vnet_rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: '${vnet_name}-${abbrs.resourcesResourceGroups}'
  location: location
  tags: tags
}

module vnet '../../../../../modules/network/virtual-network/main.bicep' = {
  name: 'vnet'
  scope: vnet_rg
  params: {
    name: '${name}-${abbrs.networkVirtualNetworks}'
    location: location
    tags: tags
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: 'EndpointSubnet'
        addressPrefix: '10.0.1.0/24'
      }
    ]
  }
}

module kvPrivateDnsZone '../../../../../modules/network/private-dns-zone/main.bicep' = {
  name: 'pep'
  scope: vnet_rg
  params: {
    #disable-next-line no-hardcoded-env-urls
    name: '${kv_name}.vault.azure.net'
    location: 'global'
    tags: tags
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: vnet.outputs.resourceId
      }
    ]
  }
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
    enablePurgeProtection: false
    enableRbacAuthorization: true
    enableSoftDelete: false
    softDeleteRetentionInDays: 7
    lock: {
      kind: 'CanNotDelete'
      name: 'This is a log name'
      notes: 'This is lock notes'
    }
    publicNetworkAccess: 'Disabled' // its disable when setting up private endpoint
    secrets: [
      {
        name: 'My Secret 3'
        value: 'My Secret value 3'
        tags: tags
      }
      {
        name: 'My Secret 4'
        value: 'My Secret value 4'
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
    privateEndpoints: [
      {
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        name: '${name}-${abbrs.networkPrivateLinkServices}'
        // privateDnsZoneName: kvPrivateDnsZone.outputs.name
        privateDnsZoneId: kvPrivateDnsZone.outputs.resourceId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              name: 'privateDnsZone'
              privateDnsZoneResourceId: kvPrivateDnsZone.outputs.resourceId
            }
          ]
        }
        privateLinkServiceConnectionName: '${name}-${abbrs.networkPrivateLinkServices}'
      }
    ]
  }
}
