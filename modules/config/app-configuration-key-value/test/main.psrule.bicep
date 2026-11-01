@description('Name of the existing App Configuration store to use as the key-value parent.')
param appConfigurationName string = 'psrule-app-config'

module keyValue '../main.bicep' = {
  name: 'appConfigurationKeyValuePsRule'
  params: {
    appConfigurationName: appConfigurationName
    name: 'psrule-test-key'
    value: 'sample-value'
    contentType: 'text/plain'
    tags: {
      environment: 'test'
    }
  }
}
