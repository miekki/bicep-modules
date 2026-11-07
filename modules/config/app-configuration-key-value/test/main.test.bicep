module keyValue_requiredParameters '../main.bicep' = {
  params: {
    appConfigurationName: 'unit-test-store'
    name: 'test-key'
    value: 'test-value'
  }
}
