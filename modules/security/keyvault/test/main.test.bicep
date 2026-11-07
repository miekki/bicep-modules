// key vault with minimal required parameters
module kv_requiredParameters '../main.bicep' = {
  params: {
    name: 'kv-minimal'
    location: 'uksouth'
    tags: {
      env: 'test'
    }
  }
}
