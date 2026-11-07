// key vault secrets with required parameters
module kv_secrets_requiredParameters '../main.bicep' = {
  params: {
    keyVaultName: 'my-kv'
    name: 'kv-secrets-name'
    value: 'kv secrets value'
  }
}
