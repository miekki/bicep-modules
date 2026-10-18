resource keyVault 'Microsoft.KeyVault/vaults@2026-05-15' existing = {
  name: 'test-keyvault'
}

module accessPolicy '../main.bicep' = {
  name: 'keyVaultAccessPolicy'
  params: {
    keyVaultName: keyVault.name
    objectId: '00000000-0000-0000-0000-000000000000'
    secretsPermissions: [
      'get'
      'list'
    ]
    keyPermissions: [
      'get'
      'getrotationpolicy'
    ]
    certificatPermissions: [
      'get'
    ]
  }
}
