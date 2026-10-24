metadata name = 'Private Endpoint Private DNS Zone Groups'
metadata description = 'This module deploys a Private Endpoint Private DNS Zone Group.'
metadata owner = 'MM'

@description('Conditional. The name of the parent private endpoint. Required if the template is used in a standalone deployment.')
param privateEndpointName string

@description('Required. Array of private DNS zone configurations of the private DNS zone group. A DNS zone group can support up to 5 DNS zones.')
@minLength(1)
@maxLength(5)
param privateDnsZoneConfigs privateDnsZoneGroupConfigType[]

@description('Optional. The name of the private DNS zone group.')
param name string = 'default'

// **********************************
// variables
// **********************************

var privateDnsZoneConfgiVar = [
  for privateDnsZoneConfig in privateDnsZoneConfigs: {
    name: privateDnsZoneConfig.?name ?? last(split(privateDnsZoneConfig.privateDnsZoneResourceId, '/'))
    properties: {
      privateDnsZoneId: privateDnsZoneConfig.privateDnsZoneResourceId
    }
  }
]

// **********************************
// Resources
// **********************************

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2025-05-01' existing = {
  name: privateEndpointName
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = {
  name: name
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: privateDnsZoneConfgiVar
  }
}

// **********************************
// Outputs
// **********************************

@description('The name of the private endpoint DNS zone group.')
output name string = privateDnsZoneGroup.name

@description('The resource ID of the private endpoint DNS zone group.')
output resourceId string = privateDnsZoneGroup.id

@description('The resource group the private endpoint DNS zone group was deployed into.')
output resourceGroupName string = resourceGroup().name

// **********************************
// Types
// **********************************

@export()
@description('The type of a private DNS zone group configuration.')
type privateDnsZoneGroupConfigType = {
  @description('Optional. The name of the private DNS zone group config.')
  name: string?

  @description('Required. The resource id of the private DNS zone.')
  privateDnsZoneResourceId: string
}
