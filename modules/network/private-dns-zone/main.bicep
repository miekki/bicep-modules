metadata name = 'Private DNS Zones'
metadata description = 'This module deploys a Private DNS zone.'
metadata owner = 'MM'

@description('Required. Private DNS zone name.')
param name string

@description('Required. Tags of the resource.')
param tags object

import { lockType } from '../../common-types/main.bicep'
@sys.description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain properties \'virtualNetworkResourceId\' and \'registrationEnabled\'. The \'vnetResourceId\' is a resource ID of a vNet to link, \'registrationEnabled\' (bool) enables automatic DNS registration in the zone for the linked vNet.')
param virtualNetworkLinks virtualNetworkLinkType[]?

@description('Optional. Array of A records.')
param a aType[]?

@description('Optional. The location of the PrivateDNSZone. Should be global.')
param location string = 'global'

import { roleAssignmentType } from '../../common-types/main.bicep'
@sys.description('Optional. Array of role assignments to create.')
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
  'Private DNS Zone Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b12aa53e-6015-4669-85d0-8515ebb3ae7f'
  )
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
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

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: name
  location: location
  tags: tags
}

module privateDnsZone_A '../private-dns-zone-a-record/main.bicep' = [
  for (aRecord, index) in (a ?? []): {
    name: '${uniqueString(deployment().name, location)}-PrivateDnsZone-ARecord-${index}'
    params: {
      privateDnsZoneName: privateDnsZone.name
      name: aRecord.name
      aRecords: aRecord.?aRecords
      metadata: aRecord.?metadata
      ttl: aRecord.?ttl ?? 3600
      roleAssignments: aRecord.?roleAssignments
    }
  }
]

module privateDnsZone_virtualNetworkLinks '../private-dns-zone-virtual-network-link/main.bicep' = [
  for (virtualNetworkLink, index) in (virtualNetworkLinks ?? []): {
    name: '${uniqueString(deployment().name, location)}-PrivateDnsZone-VNetLink-${index}'
    params: {
      privateDnsZoneName: privateDnsZone.name
      name: virtualNetworkLink.?name ?? '${last(split(virtualNetworkLink.virtualNetworkResourceId, '/'))}-vnetlink'
      virtualNetworkResourceId: virtualNetworkLink.virtualNetworkResourceId
      location: virtualNetworkLink.?location ?? 'global'
      registrationEnabled: virtualNetworkLink.?registrationEnabled ?? false
      tags: virtualNetworkLink.?tags ?? tags
    }
  }
]

var privateDnsZoneLockName = lock.?name ?? '${name}-${lock.?kind ?? 'lock'}-lock'

var privateDnsZoneLockProperties = {
  level: lock.?kind ?? 'None'
  notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
    ? 'Cannot delete resource or child resources.'
    : 'Cannot delete or modify the resource or child resources.')
}

var privateDnsZoneLockEnabled = lock.?kind != null && lock.?kind != 'None'

resource privateDnsZone_lock 'Microsoft.Authorization/locks@2020-05-01' = if (privateDnsZoneLockEnabled) {
  name: privateDnsZoneLockName
  properties: privateDnsZoneLockProperties
  scope: privateDnsZone
}

resource privateDnsZone_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(privateDnsZone.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: privateDnsZone
  }
]

// **********************************
// Outputs
// **********************************

@description('The name of the private DNS zone.')
output name string = privateDnsZone.name

@description('The resource ID of the private DNS zone.')
output resourceId string = privateDnsZone.id

// **********************************
// Types
// **********************************

@export()
@description('The type for the A record.')
type aType = {
  @description('Required. The name of the record.')
  name: string

  @description('Optional. The metadata of the record.')
  metadata: resourceInput<'Microsoft.Network/privateDnsZones/A@2024-06-01'>.properties.metadata?

  @description('Optional. The TTL of the record.')
  ttl: int?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. The list of A records in the record set.')
  aRecords: resourceInput<'Microsoft.Network/privateDnsZones/A@2024-06-01'>.properties.aRecords?
}

@export()
@description('The type for the virtual network link.')
type virtualNetworkLinkType = {
  @description('Optional. The resource name.')
  @minLength(1)
  @maxLength(80)
  name: string?

  @description('Required. The resource ID of the virtual network to link.')
  virtualNetworkResourceId: string

  @description('Optional. The Azure Region where the resource lives.')
  location: string?

  @description('Optional. Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled?.')
  registrationEnabled: bool?

  @description('Optional. Resource tags.')
  tags: resourceInput<'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01'>.tags?

  @description('Optional. The resolution type of the private-dns-zone fallback machanism.')
  resolutionPolicy: ('Default' | 'NxDomainRedirect')?
}
