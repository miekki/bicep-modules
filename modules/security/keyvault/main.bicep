metadata name = 'Azure Key Vault'
metadata description = 'Bicep module for simplified deployment of KeyVault; enables VNet integration and offers flexible configuration options.'
metadata owner = 'MM'

@description('Required. Name of Key Vault.')
param name string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags of the resource.')
param tags object



@description('Optional. Specifies whether soft delete should be enabled for the Key Vault.')
param enableSoftDelete bool = true

@description('Optional. The number of days to retain deleted data in the Key Vault.')
param softDeleteRetentionInDays int = 7

@description('Optional. Specify whether purge protection should be enabled for the Key Vault.')
param enablePurgeProtection bool = false

@description('Optional. Specify whether the Key Vault will be using RBAC. Default is false - use the access policy.')
param enableRbacAuthorization bool = false

@allowed(['standard', 'premium'])
@description('Optional. The SKU name of the Key Vault.')
param skuName string = 'standard'

@allowed(['A', 'B'])
@description('Optional. The SKU family of the Key Vault.')
param skuFamily string = 'A'

@description('Optional. Configuration for network access rules.')
param networkAcls networkAclsType = {
  defaultAction: 'Deny'
}


var varNetworkAclsIpRules = [for ip in networkAcls.?ipAllowlist ?? []: { value: ip }]

var varNetworkAclsVirtualNetworkRules = [for subnet in networkAcls.?subnetIds ?? []: {  id: subnet }]

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
    networkAcls:varNetworkAcls
  }
}

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


@description('Key vault id')
output id string = keyVault.id

@description('Key vault name')
output name string = keyVault.name
