metadata name = 'Private Endpoints'
metadata description = 'This module deploys a Private Endpoint.'

@description('Required. Name of the private endpoint resource to create.')
param name string

@description('Required. Location for all Resources.')
param location string

@description('Required. Tags to be applied on all resources/resource groups in this deployment.')
param tags object

@description('Required. Resource ID of the subnet where the endpoint needs to be created.')
param subnetResourceId string

import { lockType } from '../../common-types/main.bicep'
@description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Application security groups in which the private endpoint IP configuration is included.')
param applicationSecurityGroupResourceIds string[]?

@description('Optional. The custom name of the network interface attached to the private endpoint.')
param customNetworkInterfaceName string?

@description('Optional. A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.')
param ipConfigurations resourceInput<'Microsoft.Network/privateEndpoints@2025-05-01'>.properties.ipConfigurations?

@description('Optional. The private DNS zone group to configure for the private endpoint.')
param privateDnsZoneGroup privateDnsZoneGroupType?

import { roleAssignmentType } from '../../common-types/main.bicep'
@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

@description('Optional. Custom DNS configurations.')
param customDnsConfigs resourceInput<'Microsoft.Network/privateEndpoints@2025-05-01'>.properties.customDnsConfigs?

@description('Conditional. A grouping of information about the connection to the remote resource. Used when the network admin does not have access to approve connections to the remote resource. Required if `privateLinkServiceConnections` is empty.')
param manualPrivateLinkServiceConnections resourceInput<'Microsoft.Network/privateEndpoints@2025-05-01'>.properties.manualPrivateLinkServiceConnections?

@description('Conditional. A grouping of information about the connection to the remote resource. Required if `manualPrivateLinkServiceConnections` is empty.')
param privateLinkServiceConnections resourceInput<'Microsoft.Network/privateEndpoints@2025-05-01'>.properties.privateLinkServiceConnections?

@description('Optional. The name of the private DNS Zone name it to create A record with private ip address.')
param privateDnsZoneName string = ''

@description('Optional. The name of the private DNS A record.')
param privateDnsARecordName string = ''

@description('Optional. The number of private IP address to get from the network interface.')
param numberOfIps int = 1

@description('Optional. The ID of the private DNS Zone need it to create A record with private ip address. Use when DNS Zone is in another resource group.')
param privateDnsZoneId string?

// **********************************
// variables
// **********************************

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  'DNS Resolver Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0f2ebee7-ffd4-4fc0-b3b7-664099fdad5d'
  )
  'DNS Zone Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'befefa01-2a29-4197-83a8-272ff33ce314'
  )
  'Domain Services Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'eeaeda52-9324-47f6-8069-5d5bade478b2'
  )
  'Domain Services Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '361898ef-9ed1-48c2-849c-a832951106bb'
  )
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

var privateDnsZoneIdSub = !empty(privateDnsZoneId) ? split(privateDnsZoneId!, '/')[2] : subscription().subscriptionId
var privateDnsZoneIdRg = !empty(privateDnsZoneId) ? split(privateDnsZoneId!, '/')[4] : resourceGroup().name

// **********************************
// Resources
// **********************************

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    applicationSecurityGroups: [
      for applicationSecurityGroupResourceId in (applicationSecurityGroupResourceIds ?? []): {
        id: applicationSecurityGroupResourceId
      }
    ]
    customDnsConfigs: customDnsConfigs ?? []
    customNetworkInterfaceName: customNetworkInterfaceName ?? ''
    ipConfigurations: ipConfigurations ?? []
    manualPrivateLinkServiceConnections: manualPrivateLinkServiceConnections ?? []
    privateLinkServiceConnections: privateLinkServiceConnections ?? []
    subnet: {
      id: subnetResourceId
    }
  }
}

module privateEndpoint_privateDnsZoneGroup '../private-endpoint-private-dns-zone-group/main.bicep' = if (!empty(privateDnsZoneGroup)) {
  name: '${uniqueString(deployment().name)}-PrivateEndpoint-PrivateDnsZoneGroup'
  params: {
    name: privateDnsZoneGroup.?name
    privateEndpointName: privateEndpoint.name
    privateDnsZoneConfigs: privateDnsZoneGroup!.privateDnsZoneGroupConfigs
  }
}

var privateEndpointLockName = lock.?name ?? '${name}-${lock.?kind ?? 'lock'}-lock'

var privateEndpointLockProperties = {
  level: lock.?kind ?? 'None'
  notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
    ? 'Cannot delete resource or child resources.'
    : 'Cannot delete or modify the resource or child resources.')
}

var privateEndpointLockEnabled = lock.?kind != null && lock.?kind != 'None'

resource privateEndpoint_lock 'Microsoft.Authorization/locks@2020-05-01' = if (privateEndpointLockEnabled) {
  name: privateEndpointLockName
  properties: privateEndpointLockProperties
  scope: privateEndpoint
}

resource privateEndpoint_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(privateEndpoint.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: privateEndpoint
  }
]

module nicIp '../network-interface-get-ip/main.bicep' = {
  name: '${uniqueString((deployment().name))}-NetworkInterface-Get-IP'
  params: {
    id: privateEndpoint.properties.networkInterfaces[0].id
    numberOfIps: numberOfIps
  }
}

module privateEndpoint_DnsZoneARecord_ByName '../private-dns-zone-a-record/main.bicep' = if (!empty(privateDnsZoneName)) {
  name: '${uniqueString(deployment().name)}-PrivateEndpoint-PrivateDnsZoneARecord'
  params: {
    name: privateDnsARecordName
    privateDnsZoneName: privateDnsZoneName
    aRecords: nicIp.outputs.ips
  }
}

// privateDnsZoneId
module privateEndpoint_DnsZoneARecord_ById_1 '../private-dns-zone-a-record/main.bicep' = if (!empty(privateDnsZoneId) && !empty(privateDnsZoneGroup) && length(privateDnsZoneGroup.?privateDnsZoneGroupConfigs ?? []) >= 1) {
  scope: resourceGroup(privateDnsZoneIdSub, privateDnsZoneIdRg)
  name: '${uniqueString(deployment().name, '1')}-PrivateEndpoint-PrivateDnsZoneARecord-1'
  params: {
    name: !empty(privateDnsARecordName) ? privateDnsARecordName : '@'
    privateDnsZoneName: !empty(privateEndpoint.properties.?customDnsConfigs[0])
      ? privateEndpoint.properties.customDnsConfigs[0].?fqdn
      : ''
    aRecords: [
      {
        ipv4Address: !empty(privateEndpoint.properties.?customDnsConfigs[0])
          ? privateEndpoint.properties.customDnsConfigs[0].?ipAddresses[0]
          : ''
      }
    ]
  }
}

// **********************************
// Outputs
// **********************************

@description('The resource group the private endpoint was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the private endpoint.')
output resourceId string = privateEndpoint.id

@description('The name of the private endpoint.')
output name string = privateEndpoint.name

@description('The location the resource was deployed into.')
output location string = privateEndpoint.location

@description('The custom DNS configurations of the private endpoint.')
output customDnsConfigs resourceOutput<'Microsoft.Network/privateEndpoints@2025-05-01'>.properties.customDnsConfigs = privateEndpoint.properties.customDnsConfigs

@description('The resource IDs of the network interfaces associated with the private endpoint.')
output networkInterfaceResourceIds string[] = map(privateEndpoint.properties.networkInterfaces, nic => nic.id)

@description('The group Id for the private endpoint Group.')
output groupId string? = privateEndpoint.properties.?manualPrivateLinkServiceConnections[?0].properties.?groupIds[?0] ?? privateEndpoint.properties.?privateLinkServiceConnections[?0].properties.?groupIds[?0]

// **********************************
// Types
// **********************************

import { privateDnsZoneGroupConfigType } from '../private-endpoint-private-dns-zone-group/main.bicep'

@export()
@description('The type of a private dns zone group.')
type privateDnsZoneGroupType = {
  @description('Optional. The name of the Private DNS Zone Group.')
  name: string?

  @description('Required. The private DNS zone groups to associate the private endpoint. A DNS zone group can support up to 5 DNS zones.')
  privateDnsZoneGroupConfigs: privateDnsZoneGroupConfigType[]
}
