// key vault secrets with required parameters
test kv_secrets_requiredParameters '../main.bicep' = {
  params: {
    keyVaultName: 'my-kv'
    name: 'kv-secrets-name'
    value: 'kv secrets value'
  }
}

// key vault secrets with full parameters
test kv_secrets_fullParameters '../main.bicep' = {
  params: {
    keyVaultName: 'my-kv'
    name: 'kv-secrets-full-name'
    value: 'kv full secrets name'
    tags: {
      env: 'dev'
    }
    enabled: true
    expiryDateInSeconds: 1
    notBeforeDateInSecounds: 12
  }
}
