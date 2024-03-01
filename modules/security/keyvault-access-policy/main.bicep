metadata name = 'Azure Key Vault - Access Policy'
metadata description = 'Bicep module for simplified deployment of KeyVault - Access Policy.'
metadata owner = 'MM'

@description('Required. Name of Key Vault.')
param keyVaultName string

@description('Required. Object Id of a user, service principal or security group')
param objectId string

@description('Optional. Application id of the client making request.')
param applicationId string = ''

@description('Optional. Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = []

@description('Optional. Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keyPermissions array = []

@description('Optional. Specify the permissions to certificates. Valid values are: all, backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update')
param certificatPermissions array = []

@description('Oprional. Name of Key Vault Access Policy.')
param policyName string = 'add'

resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: policyName
  parent: keyvault
  properties: {
    accessPolicies: [
      {
        objectId: !empty(objectId) ? objectId : ''
        applicationId: !empty(applicationId) ? applicationId : null
        permissions: {
          secrets: !empty(secretsPermissions) ? secretsPermissions : []
          keys: !empty(keyPermissions) ? keyPermissions : []
          certificates: !empty(certificatPermissions) ? certificatPermissions : []
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}
