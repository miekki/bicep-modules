@description('Name of the existing Key Vault used by the test deployment.')
param keyVaultName string = 'test-keyvault'

@description('Generates a disposable test value; never use this fixture for a real secret.')
@secure()
param secretValue string = newGuid()

module secret '../main.bicep' = {
  name: '${uniqueString(deployment().name, keyVaultName)}-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: 'psrule-test-secret'
    secretValue: secretValue
  }
}
