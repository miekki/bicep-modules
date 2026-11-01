test keyValue_requiredParameters '../main.bicep' = {
  params: {
    appConfigurationName: 'unit-test-store'
    name: 'test-key'
    value: 'test-value'
  }
}

test keyValue_optionalParameters '../main.bicep' = {
  params: {
    appConfigurationName: 'unit-test-store'
    name: 'test-key-with-metadata'
    value: 'test-value'
    contentType: 'text/plain'
    tags: {
      environment: 'test'
    }
  }
}
