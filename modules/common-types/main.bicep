//  =================== //
//   Role Assignments   //
//  =================== //

@export()
@description('An AVM-aligned type for a role assignment.')
type roleAssignmentType = {
  @description('Optional. The name (as GUID) of the role assignment. If not provided, a GUID will be generated.')
  name: string?

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
}

// ===================== //
//   Private Endpoints   //
// ===================== //

type privateEndpointPrivateDnsZoneGroupType = {
  @description('Optional. The name of the Private DNS Zone Group.')
  name: string?

  @description('Required. The private DNS Zone Groups to associate the Private Endpoint. A DNS Zone Group can support up to 5 DNS zones.')
  privateDnsZoneGroupConfigs: {
    @description('Optional. The name of the private DNS Zone Group config.')
    name: string?

    @description('Required. The resource id of the private DNS zone.')
    privateDnsZoneResourceId: string
  }[]
}

type privateEndpointCustomDnsConfigType = {
  @description('Optional. FQDN that resolves to private endpoint IP address.')
  fqdn: string?

  @description('Required. A list of private IP addresses of the private endpoint.')
  ipAddresses: string[]
}

type privateEndpointIpConfigurationType = {
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
}

@export()
@description('An AVM-aligned type for a private endpoint. To be used if the private endpoint\'s default service / groupId can be assumed (i.e., for services that only have one Private Endpoint type like \'vault\' for key vault).')
type privateEndpointSingleServiceType = {
  @description('Optional. The name of the Private Endpoint.')
  name: string?

  @description('Optional. The location to deploy the Private Endpoint to.')
  location: string?

  @description('Optional. The name of the private link connection to create.')
  privateLinkServiceConnectionName: string?

  @description('Optional. The subresource to deploy the Private Endpoint for. For example "vault" for a Key Vault Private Endpoint.')
  service: string?

  @description('Required. Resource ID of the subnet where the endpoint needs to be created.')
  subnetResourceId: string

  @description('Optional. The resource ID of the Resource Group the Private Endpoint will be created in. If not specified, the Resource Group of the provided Virtual Network Subnet is used.')
  resourceGroupResourceId: string?

  @description('Optional. The private DNS Zone Group to configure for the Private Endpoint.')
  privateDnsZoneGroup: privateEndpointPrivateDnsZoneGroupType?

  @description('Optional. If Manual Private Link Connection is required.')
  isManualConnection: bool?

  @description('Optional. A message passed to the owner of the remote resource with the manual connection request.')
  @maxLength(140)
  manualConnectionRequestMessage: string?

  @description('Optional. Custom DNS configurations.')
  customDnsConfigs: privateEndpointCustomDnsConfigType[]?

  @description('Optional. A list of IP configurations of the Private Endpoint. This will be used to map to the first-party Service endpoints.')
  ipConfigurations: privateEndpointIpConfigurationType[]?

  @description('Optional. Application security groups in which the Private Endpoint IP configuration is included.')
  applicationSecurityGroupResourceIds: string[]?

  @description('Optional. The custom name of the network interface attached to the Private Endpoint.')
  customNetworkInterfaceName: string?

  @description('Optional. Specify the type of lock.')
  lock: lockType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. Tags to be applied on all resources/Resource Groups in this deployment.')
  tags: object?
}

@export()
@description('An AVM-aligned type for a private endpoint. To be used if the private endpoint\'s default service / groupId can NOT be assumed (i.e., for services that have more than one subresource, like Storage Account with Blob (blob, table, queue, file, ...).')
type privateEndpointMultiServiceType = {
  @description('Optional. The name of the private endpoint.')
  name: string?

  @description('Optional. The location to deploy the private endpoint to.')
  location: string?

  @description('Optional. The name of the private link connection to create.')
  privateLinkServiceConnectionName: string?

  @description('Required. The subresource to deploy the private endpoint for. For example "blob", "table", "queue" or "file" for a Storage Account\'s Private Endpoints.')
  service: string

  @description('Required. Resource ID of the subnet where the endpoint needs to be created.')
  subnetResourceId: string

  @description('Optional. The resource ID of the Resource Group the Private Endpoint will be created in. If not specified, the Resource Group of the provided Virtual Network Subnet is used.')
  resourceGroupResourceId: string?

  @description('Optional. The private DNS zone group to configure for the private endpoint.')
  privateDnsZoneGroup: privateEndpointPrivateDnsZoneGroupType?

  @description('Optional. If Manual Private Link Connection is required.')
  isManualConnection: bool?

  @description('Optional. A message passed to the owner of the remote resource with the manual connection request.')
  @maxLength(140)
  manualConnectionRequestMessage: string?

  @description('Optional. Custom DNS configurations.')
  customDnsConfigs: privateEndpointCustomDnsConfigType[]?

  @description('Optional. A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.')
  ipConfigurations: privateEndpointIpConfigurationType[]?

  @description('Optional. Application security groups in which the private endpoint IP configuration is included.')
  applicationSecurityGroupResourceIds: string[]?

  @description('Optional. The custom name of the network interface attached to the private endpoint.')
  customNetworkInterfaceName: string?

  @description('Optional. Specify the type of lock.')
  lock: lockType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. Tags to be applied on all resources/resource groups in this deployment.')
  tags: object?
}

// ========= //
//   Locks   //
// ========= //

@export()
@description('Type for a lock.')
type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')

  @description('Optional. Specify the notes of the lock.')
  notes: string?
}
