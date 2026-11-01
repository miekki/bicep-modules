targetScope = 'subscription'

param uniqueStr string = substring(uniqueString(subscription().id, utcNow()), 1, 3)

var companyName = 'mm'
var projectName = 'test-bicep'
var environmentName = 'dev'
var name = '${companyName}-${projectName}-${environmentName}'
var vnet_name = '${companyName}-${projectName}-${environmentName}-vnet'
var tags = { environment: environmentName }
var storeName = '${name}-${uniqueStr}-${abbrs.appConfigurationConfigurationStores}'

var location string = 'uksouth'
var abbrs = loadJsonContent('../../../../abbreviations.json')

// @description('The resource ID of an existing Log Analytics workspace.')
//param workspaceId string

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

module appStorePrivateDnsZone '../../../../../modules/network/private-dns-zone/main.bicep' = {
  name: 'pep'
  scope: vnet_rg
  params: {
    #disable-next-line no-hardcoded-env-urls
    name: '${storeName}.azconfig.io'
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

module appConfiguration '../../main.bicep' = {
  name: 'appConfigurationFullParameters'
  scope: rg
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
    publicNetworkAccess: 'Disabled'
    softDeleteRetentionInDays: 7
    keyValues: []
    replicaLocations: [
      {
        name: 'secondary'
        replicaLocation: 'westeurope'
      }
    ]
    // diagnosticSettings: {
    //   workspaceId: workspaceId
    //   logs: [
    //     {
    //       categoryGroup: 'audit'
    //       enabled: true
    //     }
    //   ]
    // }
    lock: {
      kind: 'None'
    }
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'App Configuration Data Owner'
        principalId: 'c5c1dcd6-c181-466e-a606-cd67d0532eb9'
      }
    ]
    dataPlaneProxy: {
      authenticationMode: 'Pass-through'
      privateLinkDelegation: 'Disabled'
    }
    privateEndpoints: [
      {
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        name: '${name}-${abbrs.networkPrivateLinkServices}'
        // privateDnsZoneName: appStorePrivateDnsZone.outputs.name
        privateDnsZoneId: appStorePrivateDnsZone.outputs.resourceId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              name: 'privateDnsZone'
              privateDnsZoneResourceId: appStorePrivateDnsZone.outputs.resourceId
            }
          ]
        }
        privateLinkServiceConnectionName: '${name}-${abbrs.networkPrivateLinkServices}'
      }
    ]
  }
}
