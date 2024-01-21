metadata name = 'Virtual Networks'
metadata description = 'This module deploy Virtual Networks'
metadata owner = 'MM'

@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Tags of the resource.')
param tags object = {}

@allowed([ 'new', 'existing', 'none' ])
@description('Create a new, use an existing, or provide no default NSG.')
param newOrExistingNSG string = 'none'

@description('Name of default NSG to use for subnets.')
param networkSecurityGroupName string = uniqueString(resourceGroup().name, location)

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-06-01' = if (newOrExistingNSG == 'new') {
  name: networkSecurityGroupName
  location: location
}

resource existingNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-06-01' existing = if (newOrExistingNSG == 'existing') {
  name: networkSecurityGroupName
}

var networkSecurityGroupId = { id: newOrExistingNSG == 'new' ? networkSecurityGroup.id : existingNetworkSecurityGroup.id }

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    //ddosProtectionPlan: !empty(ddosProtectionPlanId) ? ddosProtectionPlan : null
    //dhcpOptions: !empty(dnsServers) ? { dnsServers: array(dnsServers) } : null
    //enableDdosProtection: !empty(ddosProtectionPlanId)
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
        //applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
        ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
        natGateway: contains(subnet, 'natGatewayId') ? { id: subnet.natGatewayId } : null
        networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? { id: subnet.networkSecurityGroupId } : (newOrExistingNSG != 'none' ? networkSecurityGroupId : null)
        //privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
        //privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
        routeTable: contains(subnet, 'routeTableId') ? { id: subnet.routeTableId } : null
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
      }
    }]
  }
}

resource virtualNetwork_lock 'Microsoft.Authorization/locks@2020-05-01' = if (lock != 'NotSpecified') {
  name: '${virtualNetwork.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: virtualNetwork
}
