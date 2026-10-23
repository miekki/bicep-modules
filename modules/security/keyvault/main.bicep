metadata name = 'Azure Key Vault.'
metadata description = 'Deploys an Azure Key Vault with configurable authorization, network access, private endpoints, role assignments, and resource locks.'
metadata owner = 'MM'

@description('Required. Name of Key Vault.')
param name string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags to apply to the Key Vault and, unless overridden, its private endpoints.')
param tags object

@description('Optional. Specifies whether soft delete should be enabled for the Key Vault. The default is true.')
param enableSoftDelete bool = true

@minValue(7)
@maxValue(90)
@description('Optional. The number of days to retain deleted data in the Key Vault. The default is 90 days.')
param softDeleteRetentionInDays int = 90

@description('Optional. Specify whether purge protection should be enabled for the Key Vault. The default is true. Once enabled, purge protection cannot be disabled.')
param enablePurgeProtection bool = true

@description('Optional. Specify whether the Key Vault will be using RBAC. The default is true.')
param enableRbacAuthorization bool = true

@allowed(['standard', 'premium'])
@description('Optional. The SKU name of the Key Vault. The default is "standard".')
param skuName string = 'standard'

@allowed(['A', 'B'])
@description('Optional. The SKU family of the Key Vault. The default is "A".')
param skuFamily string = 'A'

@description('Optional. Configuration for network access rules. By default, all network traffic is denied and no trusted-service bypass is enabled.')
param networkAcls networkAclsType = {
  defaultAction: 'Deny'
}

@description('Optional. Controls whether public network access is enabled for the Key Vault. When omitted, it is disabled if private endpoints are configured and enabled otherwise. Network ACLs still apply.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

import { lockType } from '../../common-types/main.bicep'
@description('Optional. Management lock for the Key Vault. Use CanNotDelete or ReadOnly to apply a lock; omit it or use None for no lock.')
param lock lockType?

import { privateEndpointSingleServiceType } from '../../common-types/main.bicep'
@description('Optional. Private endpoints to create for the Key Vault. Each endpoint requires a subnet resource ID and can include a private DNS zone group. Public network access is disabled by default when one or more endpoints are configured.')
param privateEndpoints privateEndpointSingleServiceType[]?

import { roleAssignmentType } from '../../common-types/main.bicep'
@description('Optional. Role assignments to create at the Key Vault scope. Supply a supported built-in role name, role definition GUID, or full role definition resource ID.')
param roleAssignments roleAssignmentType[]?

// **********************************
// variables
// **********************************
var varNetworkAclsIpRules = [for ip in networkAcls.?ipAllowlist ?? []: { value: ip }]

var varNetworkAclsVirtualNetworkRules = [for subnet in networkAcls.?subnetIds ?? []: { id: subnet }]

var varNetworkAcls = {
  bypass: networkAcls.?bypass ?? 'None'
  defaultAction: networkAcls.defaultAction
  ipRules: varNetworkAclsIpRules
  virtualNetworkRules: varNetworkAclsVirtualNetworkRules
}

var effectivePublicNetworkAccess = !empty(publicNetworkAccess)
  ? publicNetworkAccess
  : (!empty(privateEndpoints) ? 'Disabled' : 'Enabled')

// Resolve the supported built-in role display names to IDs; other values are treated as role IDs or GUIDs.
var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  'Key Vault Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  )
  'Key Vault Certificates Officer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'a4417e6f-fecd-4de8-b567-7b0420556985'
  )
  'Key Vault Certificate User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'db79e9a7-68ee-4b58-9aeb-b90e7c24fcba'
  )
  'Key Vault Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f25e0fa2-a7c8-4377-a976-54943a77a395'
  )
  'Key Vault Crypto Officer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
  )
  'Key Vault Crypto Service Encryption User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'e147488a-f6f5-4113-8e2d-b22465e65bf6'
  )
  'Key Vault Crypto User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '12338af0-0e69-4776-bea7-57ae8d297424'
  )
  'Key Vault Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '21090545-7ca7-4776-b22c-e363652d74d2'
  )
  'Key Vault Secrets Officer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  )
  'Key Vault Secrets User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '4633458b-17de-408a-b874-0445c86b69e6'
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

resource keyVault 'Microsoft.KeyVault/vaults@2026-05-15' = {
  name: name
  location: location
  tags: tags
  properties: {
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? enablePurgeProtection : null
    enableRbacAuthorization: enableRbacAuthorization
    sku: {
      family: skuFamily
      name: skuName
    }
    tenantId: subscription().tenantId
    networkAcls: varNetworkAcls
    publicNetworkAccess: effectivePublicNetworkAccess
  }
}

module keyVault_privateEndpoints '../../network/private-endpoint/main.bicep' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-keyVault-PrivateEndpoint-${index}'
    scope: resourceGroup(
      split(privateEndpoint.?resourceGroupResourceId ?? resourceGroup().id, '/')[2],
      split(privateEndpoint.?resourceGroupResourceId ?? resourceGroup().id, '/')[4]
    )
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
              properties: {
                privateLinkServiceId: keyVault.id
                groupIds: [
                  privateEndpoint.?service ?? 'vault'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
              properties: {
                privateLinkServiceId: keyVault.id
                groupIds: [
                  privateEndpoint.?service ?? 'vault'
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
    }
  }
]

var keyVaultLockName = lock.?name ?? '${name}-${lock.?kind ?? 'lock'}-lock'

var keyVaultLockProperties = {
  level: lock.?kind ?? 'None'
  notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
    ? 'Cannot delete resource or child resources.'
    : 'Cannot delete or modify the resource or child resources.')
}

var keyVaultLockEnabled = lock.?kind != null && lock.?kind != 'None'

resource keyVault_lock 'Microsoft.Authorization/locks@2020-05-01' = if (keyVaultLockEnabled) {
  name: keyVaultLockName
  properties: keyVaultLockProperties
  scope: keyVault
}

resource keyVault_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(keyVault.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: keyVault
  }
]
// **********************************
// Outputs
// **********************************

@description('Key vault id')
output resourceId string = keyVault.id

@description('Key vault name')
output name string = keyVault.name

@description('The URI of the key vault.')
output uri string = keyVault.properties.vaultUri

// **********************************
// Types
// **********************************

type networkAclsType = {
  @description('Specifies whether trusted Azure services can bypass the network ACLs. AzureServices enables the bypass; None disables it.')
  bypass: ('AzureServices' | 'None')?

  @description('Specifies whether all network access is allowed or denied when no other rules match.')
  defaultAction: ('Allow' | 'Deny')

  @description('Specifies the IP or IP range in CIDR format to be allowed to connect. Only IPV4 address is allowed.')
  ipAllowlist: string[]?

  @description('Sets the virtual network rules.')
  subnetIds: string[]?
}

// **********************************
// Assertions
// **********************************

assert lockBehaviorMatchesInput = lock == null
  ? !keyVaultLockEnabled && keyVaultLockProperties.level == 'None' && keyVaultLockProperties.notes == 'Cannot delete or modify the resource or child resources.'
  : keyVaultLockEnabled == (lock.?kind != 'None') && keyVaultLockProperties.level == lock.?kind && keyVaultLockProperties.notes == (lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'))

assert networkAclsDefaultActionMatchesInput = varNetworkAcls.defaultAction == networkAcls.defaultAction
assert networkAclsBypassMatchesInput = varNetworkAcls.bypass == (networkAcls.?bypass ?? 'None')
assert networkAclIpRuleCountMatchesInput = length(varNetworkAcls.ipRules) == length(networkAcls.?ipAllowlist ?? [])
assert networkAclSubnetRuleCountMatchesInput = length(varNetworkAcls.virtualNetworkRules) == length(networkAcls.?subnetIds ?? [])
assert publicNetworkAccessMatchesInput = effectivePublicNetworkAccess == (!empty(publicNetworkAccess)
  ? publicNetworkAccess
  : (!empty(privateEndpoints) ? 'Disabled' : 'Enabled'))
