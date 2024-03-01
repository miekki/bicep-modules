metadata name = 'Azure Key Vault'
metadata description = 'Bicep module for simplified deployment of KeyVault; enables VNet integration and offers flexible configuration options.'
metadata owner = 'MM'

@description('Required. Name of Key Vault.')
param name string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags of the resource.')
param tags object

@description('Required. Provide Log Analytics Workspace Id for diagnostics settings.')
param workspaceId string

@description('Optional. Specifies whether soft delete should be enabled for the Key Vault.')
param enableSoftDelete bool = true

@description('Optional. The number of days to retain deleted data in the Key Vault.')
param softDeleteRetentionInDays int = 7

@description('Optional. Specify whether purge protection should be enabled for the Key Vault.')
param enablePurgeProtection bool = true

@description('Optional. Specify whether the Key Vault will be using RBAC. Default is false - use the access policy.')
param enableRbacAuthorization bool = true

@allowed([ 'standard', 'premium' ])
@description('Optional. The SKU name of the Key Vault.')
param skuName string = 'standard'

@allowed([ 'A', 'B' ])
@description('Optional. The SKU family of the Key Vault.')
param skuFamily string = 'A'

@description('Optional. Configuration for network access rules.')
param networkAcls networkAclsType = {
  defaultAction: 'Deny'
}

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.')
param privateEndpoints privateEndpointType

@description('Optional. The lock settings of the service.')
param lock lockType

// for a list with build in rbac for key vault please have a look https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli
// Key Vault Secrets Officer - Perform any action on the secrets of a key vault, except manage permissions. - b86a8fe4-44ce-4948-aee5-eccb2c155cd7
// Key Vault Secrets User - Read secret contents including secret portion of a certificate with private key - 4633458b-17de-408a-b874-0445c86b69e6
//
// Key Vault Certificates Officer - Perform any action on the certificates of a key vault, except manage permissions. - a4417e6f-fecd-4de8-b567-7b0420556985
// Key Vault Certificate User - Read entire certificate contents including secret and key portion - db79e9a7-68ee-4b58-9aeb-b90e7c24fcba
//
// Key Vault Crypto Officer - Perform any action on the keys of a key vault, except manage permissions. - 14b46e9e-c2b7-41b4-b07b-48a6ebf60603
// Key Vault Crypto User - Perform cryptographic operations using keys. - 12338af0-0e69-4776-bea7-57ae8d297424
@description('RBAC Role Assignments to apply to each RBAC policy')
param roleAssignments array = [
  'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
]

@description('List of RBAC policies to assign to the Key Vault')
param rbacPolicies array = []

// var builtInRoleNames = {
//   Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
//   'Key Vault Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
//   'Key Vault Certificates Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')
//   'Key Vault Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f25e0fa2-a7c8-4377-a976-54943a77a395')
//   'Key Vault Crypto Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
//   'Key Vault Crypto Service Encryption User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6')
//   'Key Vault Crypto User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
//   'Key Vault Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
//   'Key Vault Secrets Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
//   'Key Vault Secrets User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
//   Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
//   Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
//   'Role Based Access Control Administrator (Preview)': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f58310d9-a9f6-439a-9e8d-f62e7b41a168')
//   'User Access Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
// }

var varNetworkAclsIpRules = [for ip in networkAcls.?ipAllowlist ?? []: { value: ip }]

var varNetworkAclsVirtualNetworkRules = [for subnet in networkAcls.?subnetIds ?? []: { id: subnet }]

var varNetworkAcls = {
  bypass: networkAcls.?bypass ?? 'AzureServices'
  defaultAction: networkAcls.defaultAction
  ipRules: varNetworkAclsIpRules
  virtualNetworkRules: varNetworkAclsVirtualNetworkRules
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    sku: {
      family: skuFamily
      name: skuName
    }
    tenantId: subscription().tenantId
    networkAcls: varNetworkAcls
    publicNetworkAccess: !empty(publicNetworkAccess) ? publicNetworkAccess : ((!empty(privateEndpoints ?? []) && empty(networkAcls ?? {})) ? 'Disabled' : null)
  }
}

module rbacRoleAssignments 'roleAssignment.bicep' = [for rbacRole in roleAssignments: {
  name: guid(name, rbacRole)
  params: {
    keyVaultName: keyVault.name
    rbacPolicies: rbacPolicies
    rbacRole: rbacRole
  }
}]

resource log 'microsoft.insights/diagnosticSettings@2016-09-01' = {
  name: 'service' // '${keyVault.name}-diagnostics'
  location: location
  scope: keyVault
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

resource keyVault_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot delete or modify the resource or child resources.'
  }
  scope: keyVault
}

@description('Key vault id')
output id string = keyVault.id

@description('Key vault name')
output name string = keyVault.name

type networkAclsType = {
  @description('Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.')
  bypass: ('AzureServices' | 'None')?

  @description('Specifies whether all network access is allowed or denied when no other rules match.')
  defaultAction: ('Allow' | 'Deny')

  @description('Specifies the IP or IP range in CIDR format to be allowed to connect. Only IPV4 address is allowed.')
  ipAllowlist: string[]?

  @description('Sets the virtual network rules.')
  subnetIds: string[]?
}

type privateEndpointType = {

  @description('Optional. The name of the private endpoint.')
  name: string?

  @description('Optional. The location to deploy the private endpoint to.')
  location: string?

  @description('Optional. The service (sub-) type to deploy the private endpoint for. For example "vault" or "blob".')
  service: string?

  @description('Required. Resource ID of the subnet where the endpoint needs to be created.')
  subnetResourceId: string

  @description('Optional. The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided.')
  privateDnsZoneGroupName: string?

  @description('Optional. The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones.')
  privateDnsZoneResourceIds: string[]?

  @description('Optional. Custom DNS configurations.')
  customDnsConfigs: {
    @description('Required. Fqdn that resolves to private endpoint IP address.')
    fqdn: string?

    @description('Required. A list of private IP addresses of the private endpoint.')
    ipAddresses: string[]
  }[]?

  @description('Optional. A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.')
  ipConfigurations: {
    @description('Required. The name of the resource that is unique within a resource group.')
    name: string

    @description('Required. Properties of private endpoint IP configurations.')
    properties: {
      @description('Required. The ID of a group obtained from the remote resource that this private endpoint should connect to.')
      groupId: string

      @description('Required. The member name of a group obtained from the remote resource that this private endpoint should connect to.')
      memberName: string

      @description('Required. A private IP address obtained from the private endpoint\'s subnet.')
      privateIPAddress: string
    }
  }[]?

  @description('Optional. Application security groups in which the private endpoint IP configuration is included.')
  applicationSecurityGroupResourceIds: string[]?

  @description('Optional. The custom name of the network interface attached to the private endpoint.')
  customNetworkInterfaceName: string?

  @description('Optional. Specify the type of lock.')
  lock: lockType

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType

  @description('Optional. Tags to be applied on all resources/resource groups in this deployment.')
  tags: object?

  @description('Optional. Manual PrivateLink Service Connections.')
  manualPrivateLinkServiceConnections: array?

  @description('Optional. Enable/Disable usage telemetry for module.')
  enableTelemetry: bool?
}[]?

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?
}?

type accessPoliciesType = {
  @description('Optional. The tenant ID that is used for authenticating requests to the key vault.')
  tenantId: string?

  @description('Required. The object ID of a user, service principal or security group in the tenant for the vault.')
  objectId: string

  @description('Optional. Application ID of the client making request on behalf of a principal.')
  applicationId: string?

  @description('Required. Permissions the identity has for keys, secrets and certificates.')
  permissions: {
    @description('Optional. Permissions to keys.')
    keys: ('all' | 'backup' | 'create' | 'decrypt' | 'delete' | 'encrypt' | 'get' | 'getrotationpolicy' | 'import' | 'list' | 'purge' | 'recover' | 'release' | 'restore' | 'rotate' | 'setrotationpolicy' | 'sign' | 'unwrapKey' | 'update' | 'verify' | 'wrapKey')[]?

    @description('Optional. Permissions to secrets.')
    secrets: ('all' | 'backup' | 'delete' | 'get' | 'list' | 'purge' | 'recover' | 'restore' | 'set')[]?

    @description('Optional. Permissions to certificates.')
    certificates: ('all' | 'backup' | 'create' | 'delete' | 'deleteissuers' | 'get' | 'getissuers' | 'import' | 'list' | 'listissuers' | 'managecontacts' | 'manageissuers' | 'purge' | 'recover' | 'restore' | 'setissuers' | 'update')[]?

    @description('Optional. Permissions to storage accounts.')
    storage: ('all' | 'backup' | 'delete' | 'deletesas' | 'get' | 'getsas' | 'list' | 'listsas' | 'purge' | 'recover' | 'regeneratekey' | 'restore' | 'set' | 'setsas' | 'update')[]?
  }
}[]?

type roleAssignmentType = {
  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}[]?

type diagnosticSettingType = {
  @description('Optional. The name of diagnostic setting.')
  name: string?

  @description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to \'\' to disable log collection.')
  logCategoriesAndGroups: {
    @description('Optional. Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.')
    category: string?

    @description('Optional. Name of a Diagnostic Log category group for a resource type this setting is applied to. Set to `allLogs` to collect all logs.')
    categoryGroup: string?
  }[]?

  @description('Optional. The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to \'\' to disable metric collection.')
  metricCategories: {
    @description('Required. Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.')
    category: string
  }[]?

  @description('Optional. A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.')
  logAnalyticsDestinationType: ('Dedicated' | 'AzureDiagnostics')?

  @description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  workspaceResourceId: string?

  @description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  storageAccountResourceId: string?

  @description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
  eventHubAuthorizationRuleResourceId: string?

  @description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  eventHubName: string?

  @description('Optional. The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.')
  marketplacePartnerResourceId: string?
}[]?
