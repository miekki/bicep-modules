metadata name = 'Private DNS Zone Virtual Network Link'
metadata description = 'This module deploys a Private DNS Zone Virtual Network Link.'
metadata owner = 'MM'

@description('Required. The name of the parent Private DNS zone.')
param privateDnsZoneName string

@description('Required. Link to another virtual network resource ID.')
param virtualNetworkResourceId string

@description('Required. Tags of the resource.')
param tags object

@description('Optional. The name of the virtual network link.')
param name string = '${last(split(virtualNetworkResourceId, '/'))}-vnetlink'

@description('Optional. The location of the PrivateDNSZone. Should be global.')
param location string = 'global'

@description('Optional. Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled?.')
param registrationEnabled bool = false

// **********************************
// Resources
// **********************************

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: name
  parent: privateDnsZone
  location: location
  tags: tags
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetworkResourceId
    }
  }
}

// **********************************
// Outputs
// **********************************

@description('The name of the deployed virtual network link.')
output name string = virtualNetworkLink.name

@description('The resource ID of the deployed virtual network link.')
output resourceId string = virtualNetworkLink.id
