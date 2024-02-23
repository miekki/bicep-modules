metadata name = 'Azure Key Vault - Secrets'
metadata description = 'Bicep module for simplified deployment of KeyVault - Secrets.'
metadata owner = 'MM'

@description('Required. Name of Key Vault.')
param keyVaultName string

@description('Required. Secret name.')
param secretName string

@description('Required. Secret value')
@secure()
param secretValue string

resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyvault
  name: secretName
  properties: {
    value: secretValue
  }
}
