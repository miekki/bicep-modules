metadata name = 'Virtual Networks'
metadata description = 'This module deploy Virtual Networks'
metadata owner = 'MM'

@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags of the resource.')
param tags object

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

import { lockType } from '../../common-types/main.bicep'
@description('Optional. The lock settings of the service.')
param lock lockType?

@allowed(['new', 'existing', 'none'])
@description('Create a new, use an existing, or provide no default NSG.')
param newOrExistingNSG string = 'none'

@description('Name of default NSG to use for subnets.')
param networkSecurityGroupName string = uniqueString(resourceGroup().name, location)

import { roleAssignmentType } from '../../common-types/main.bicep'
@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

// **********************************
// variables
// **********************************

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  'Network Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '4d97b98b-1d4f-4787-a291-c67834d212e7'
  )
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// **********************************
// Resources
// **********************************

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-09-01' = if (newOrExistingNSG == 'new') {
  name: networkSecurityGroupName
  location: location
  tags: tags
}

resource existingNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-09-01' existing = if (newOrExistingNSG == 'existing') {
  name: newOrExistingNSG == 'existing' ? networkSecurityGroupName : '${networkSecurityGroupName}-existing'
}

var networkSecurityGroupId = {
  id: newOrExistingNSG == 'new' ? networkSecurityGroup.id : existingNetworkSecurityGroup.id
}

var virtualNetworkSubnets = [
  for subnet in subnets: {
    name: subnet.name
    properties: {
      addressPrefix: subnet.addressPrefix
      defaultOutboundAccess: false
      addressPrefixes: subnet.?addressPrefixes ?? []
      delegations: subnet.?delegations ?? []
      ipAllocations: subnet.?ipAllocations ?? []
      natGateway: !empty(subnet.?natGatewayId) ? { id: subnet.natGatewayId } : null
      networkSecurityGroup: !empty(subnet.?networkSecurityGroupId)
        ? { id: subnet.networkSecurityGroupId }
        : (newOrExistingNSG != 'none' ? networkSecurityGroupId : null)
      routeTable: !empty(subnet.?routeTableId) ? { id: subnet.routeTableId } : null
      serviceEndpoints: subnet.?serviceEndpoints ?? []
      serviceEndpointPolicies: subnet.?serviceEndpointPolicies ?? []
    }
  }
]

var virtualNetworkProperties = {
  addressSpace: {
    addressPrefixes: addressPrefixes
  }
  subnets: virtualNetworkSubnets
}

var inputSubnetNames = [for subnet in subnets: subnet.name]
var inputSubnetPrefixes = [for subnet in subnets: subnet.addressPrefix]
var deployedSubnetNames = [for subnet in virtualNetworkSubnets: subnet.name]
var deployedSubnetPrefixes = [for subnet in virtualNetworkSubnets: subnet.properties.addressPrefix]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2026-01-01' = {
  name: name
  location: location
  tags: tags
  properties: virtualNetworkProperties
}

var virtualNetworkLockName = lock.?name ?? '${name}-${lock.?kind ?? 'lock'}-lock'

var virtualNetworkLockProperties = {
  level: lock.?kind ?? 'None'
  notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
    ? 'Cannot delete resource or child resources.'
    : 'Cannot delete or modify the resource or child resources.')
}

var virtualNetworkLockEnabled = lock.?kind != null && lock.?kind != 'None'

resource virtualNetwork_lock 'Microsoft.Authorization/locks@2020-05-01' = if (virtualNetworkLockEnabled) {
  name: virtualNetworkLockName
  properties: virtualNetworkLockProperties
  scope: virtualNetwork
}

resource virtualNetwork_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(virtualNetwork.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: virtualNetwork
  }
]

// **********************************
// Outputs
// **********************************

@description('The resorce ID of the virtual network')
output resourceId string = virtualNetwork.id

@description('The name of the virtual network')
output name string = virtualNetwork.name

@description('The names of yhe deployed subnets')
output subnetNames array = [for subnet in subnets: subnet.name]

@description('The resource IDs of the deployed subnets')
output subnetResourceIds array = [
  for subnet in subnets: az.resourceId('Microsoft.Network/virtualNetworks/subnets', name, subnet.name)
]

// **********************************
// Assertions
// **********************************

assert virtualNetworkNameMatchesInput = virtualNetwork.name == name
assert virtualNetworkIdMatchesName = virtualNetwork.id == az.resourceId('Microsoft.Network/virtualNetworks', name)
assert addressPrefixesMatchInput = virtualNetworkProperties.addressSpace.addressPrefixes == addressPrefixes
assert subnetCountMatchesInput = length(virtualNetworkProperties.subnets) == length(subnets)
assert subnetNamesMatchInput = deployedSubnetNames == inputSubnetNames
assert subnetPrefixesMatchInput = deployedSubnetPrefixes == inputSubnetPrefixes
assert lockBehaviorMatchesInput = lock == null
  ? !virtualNetworkLockEnabled && virtualNetworkLockProperties.level == 'None' && virtualNetworkLockProperties.notes == 'Cannot delete or modify the resource or child resources.'
  : virtualNetworkLockEnabled == (lock.?kind != 'None') && virtualNetworkLockProperties.level == lock.?kind && virtualNetworkLockProperties.notes == (lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'))
