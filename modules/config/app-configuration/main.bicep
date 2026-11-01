metadata name = 'App Configuration Stores'
metadata description = 'This module deploys an App Configuration Store.'
metadata owner = 'MM'

import {
  lockType
  managedIdentityAllType
  privateEndpointOutputType
  privateEndpointSingleServiceType
  roleAssignmentType
} from '../../common-types/main.bicep'

@description('Required. Name of the Azure App Configuration.')
param name string

@description('Required. Location for all Resources.')
param location string

@description('Required. Tags of the resource.')
param tags object

@allowed([
  'Free'
  'Developer'
  'Standard'
  'Premium'
])
@description('Optional. Pricing tier of App Configuration.')
param sku string = 'Standard'

@allowed([
  'Default'
  'Recover'
])
@description('Optional. Indicates whether the configuration store need to be recovered.')
param createMode string = 'Default'

@description('Optional. Disables all authentication methods other than AAD authentication.')
param disableLocalAuth bool = true

@description('Optional. Property specifying whether protection against purge is enabled for this configuration store. Defaults to true unless sku is set to Free, since purge protection is not available in Free tier.')
param enablePurgeProtection bool = true

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string?

@description('Optional. The amount of time in days that the configuration store will be retained when it is soft deleted.')
@minValue(1)
@maxValue(7)
param softDeleteRetentionInDays int = 1

@description('Optional. All Key / Values to create. Requires local authentication to be enabled.')
param keyValues array?

@description('Optional. All Replicas to create.')
param replicaLocations replicaLocationType[]?

@description('Optional. Diagnostic settings to record interactions with data or the settings of the App Configuration Store.')
param diagnosticSettings diagnosticSettingsType?

@description('Optional. Property specifying the configuration of data plane proxy for Azure Resource Manager (ARM).')
param dataPlaneProxy dataPlaneProxyType?

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentityAllType?

@description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.')
param privateEndpoints privateEndpointSingleServiceType[]?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

// **********************************
// variables
// **********************************

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : null)
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

var builtInRoleNames = {
  'App Compliance Automation Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0f37683f-2463-46b6-9ce7-9b788b988ba2'
  )
  'App Compliance Automation Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'ffc6bbe0-e443-4c3b-bf54-26581bb2f78e'
  )
  'App Configuration Data Owner': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'
  )
  'App Configuration Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '516239f1-63e1-4d78-a4de-a74fb236a071'
  )
  'App Configuration Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '175b81b9-6e0d-490a-85e4-0d422273c10c'
  )
  'App Configuration Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'fe86443c-f201-4fc4-9d2a-ac61149fbda0'
  )
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
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

var effectiveEnablePurgeProtection = sku == 'Free' || sku == 'Developer' ? false : enablePurgeProtection
var effectiveSoftDeleteRetentionInDays = sku == 'Free' || sku == 'Developer' ? 0 : softDeleteRetentionInDays
var effectivePublicNetworkAccess = !empty(publicNetworkAccess)
  ? any(publicNetworkAccess)
  : (!empty(privateEndpoints) ? 'Disabled' : 'Enabled')

// **********************************
// Resources
// **********************************

resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  identity: identity
  properties: {
    createMode: createMode
    disableLocalAuth: disableLocalAuth
    enablePurgeProtection: effectiveEnablePurgeProtection
    publicNetworkAccess: effectivePublicNetworkAccess
    softDeleteRetentionInDays: effectiveSoftDeleteRetentionInDays
    dataPlaneProxy: !empty(dataPlaneProxy)
      ? {
          authenticationMode: dataPlaneProxy.?authenticationMode ?? 'Pass-through'
          privateLinkDelegation: dataPlaneProxy!.privateLinkDelegation
        }
      : null
  }
}

@batchSize(1)
resource configurationStore_replicas 'Microsoft.AppConfiguration/configurationStores/replicas@2025-08-01-preview' = [
  for (replicaLocation, index) in (replicaLocations ?? []): {
    name: replicaLocation.?name ?? uniqueString(deployment().name, replicaLocation.replicaLocation)
    parent: configurationStore
    location: replicaLocation.replicaLocation
  }
]

#disable-next-line use-recent-api-versions
resource configurationStore_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticSettings)) {
  name: 'appconfig-diagnostics'
  scope: configurationStore
  properties: {
    // The resource is conditional; this fallback only supports static evaluation when diagnostics are omitted.
    #disable-next-line use-resource-id-functions
    workspaceId: diagnosticSettings.?workspaceId ?? resourceId(
      'Microsoft.OperationalInsights/workspaces',
      'unused-workspace'
    )
    logs: diagnosticSettings.?logs ?? []
  }
}

module configurationStore_keyValues '../app-configuration-key-value/main.bicep' = [
  for (keyValue, index) in (keyValues ?? []): {
    name: '${uniqueString(deployment().name, location)}-AppConfig-KeyValues-${index}'
    params: {
      appConfigurationName: configurationStore.name
      name: keyValue.name
      value: keyValue.value
      contentType: keyValue.?contentType
      tags: keyValue.?tags ?? tags
    }
  }
]

@batchSize(1)
module configurationStore_privateEndpoints '../../network/internal-modules/private-endpoint/main.bicep' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-configStore-PrivateEndpoint-${index}'
    scope: resourceGroup(
      split(privateEndpoint.?resourceGroupResourceId ?? resourceGroup().id, '/')[2],
      split(privateEndpoint.?resourceGroupResourceId ?? resourceGroup().id, '/')[4]
    )
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(configurationStore.id, '/'))}-${privateEndpoint.?service ?? 'configurationStores'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(configurationStore.id, '/'))}-${privateEndpoint.?service ?? 'configurationStores'}-${index}'
              properties: {
                privateLinkServiceId: configurationStore.id
                groupIds: [
                  privateEndpoint.?service ?? 'configurationStores'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(configurationStore.id, '/'))}-${privateEndpoint.?service ?? 'configurationStores'}-${index}'
              properties: {
                privateLinkServiceId: configurationStore.id
                groupIds: [
                  privateEndpoint.?service ?? 'configurationStores'
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2020-06-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      privateDnsZoneGroup: privateEndpoint.?privateDnsZoneGroup
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? tags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
      //Private DNS zone in this same resource group
      privateDnsZoneName: privateEndpoint.?privateDnsZoneName
      privateDnsARecordName: !empty(privateEndpoint.?privateDnsZoneName) ? configurationStore.name : null
      numberOfIps: 1
      // Existing Private DNS zone in this same or other resource group
      privateDnsZoneId: privateEndpoint.?privateDnsZoneId
    }
  }
]

var configurationStoreLockName = lock.?name ?? '${name}-${lock.?kind ?? 'lock'}-lock'

var configurationStoreLockProperties = {
  level: lock.?kind ?? 'None'
  notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
    ? 'Cannot delete resource or child resources.'
    : 'Cannot delete or modify the resource or child resources.')
}

var configurationStoreLockEnabled = lock.?kind != null && lock.?kind != 'None'

resource configurationStore_lock 'Microsoft.Authorization/locks@2020-05-01' = if (configurationStoreLockEnabled) {
  name: configurationStoreLockName
  properties: configurationStoreLockProperties
  scope: configurationStore
}

resource configurationStore_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(
      configurationStore.id,
      roleAssignment.principalId,
      roleAssignment.roleDefinitionId
    )
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: configurationStore
  }
]

// **********************************
// Outputs
// **********************************

@description('The resource ID of the app configuration.')
output resourceId string = configurationStore.id

@description('The name of the app configuration.')
output name string = configurationStore.name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = configurationStore.?identity.?principalId

@description('The endpoint of the app configuration.')
output endpoint string = configurationStore.properties.endpoint

@description('The private endpoints of the app configuration.')
output privateEndpoints privateEndpointOutputType[] = [
  for (item, index) in (privateEndpoints ?? []): {
    name: configurationStore_privateEndpoints[index].outputs.name
    resourceId: configurationStore_privateEndpoints[index].outputs.resourceId
    groupId: configurationStore_privateEndpoints[index].outputs.?groupId!
    customDnsConfigs: configurationStore_privateEndpoints[index].outputs.customDnsConfigs
    networkInterfaceResourceIds: configurationStore_privateEndpoints[index].outputs.networkInterfaceResourceIds
  }
]

// **********************************
// Types
// **********************************

@export()
@description('The type for the data plane proxy.')
type dataPlaneProxyType = {
  @description('Optional. The data plane proxy authentication mode. This property manages the authentication mode of request to the data plane resources. \'Pass-through\' is recommended.')
  authenticationMode: ('Local' | 'Pass-through')?

  @description('Required. The data plane proxy private link delegation. This property manages if a request from delegated Azure Resource Manager (ARM) private link is allowed when the data plane resource requires private link.')
  privateLinkDelegation: 'Disabled' | 'Enabled'
}

@export()
@description('The type for a replica location')
type replicaLocationType = {
  @description('Required. Location of the replica.')
  replicaLocation: string

  @description('Optional. Name of the replica.')
  name: string?
}

@export()
@description('The type for App Configuration diagnostic settings.')
type diagnosticSettingsType = {
  @description('Required. The resource ID of the Log Analytics workspace to send diagnostic logs to.')
  workspaceId: string

  @description('Required. The log categories or category groups to enable.')
  logs: {
    @description('Optional. The log category to enable.')
    category: string?

    @description('Optional. The log category group to enable.')
    categoryGroup: string?

    @description('Required. Whether this log category or group is enabled.')
    enabled: bool
  }[]
}

// **********************************
// Assertions
// **********************************

assert purgeProtectionIsDisabledForFreeOrDeveloper = (sku == 'Free' || sku == 'Developer')
  ? effectiveEnablePurgeProtection == false
  : effectiveEnablePurgeProtection == enablePurgeProtection

assert softDeleteRetentionIsZeroForFreeOrDeveloper = (sku == 'Free' || sku == 'Developer')
  ? effectiveSoftDeleteRetentionInDays == 0
  : effectiveSoftDeleteRetentionInDays == softDeleteRetentionInDays

assert publicNetworkAccessMatchesInputOrPrivateEndpointDefault = effectivePublicNetworkAccess == (!empty(publicNetworkAccess)
  ? publicNetworkAccess
  : (!empty(privateEndpoints) ? 'Disabled' : 'Enabled'))
