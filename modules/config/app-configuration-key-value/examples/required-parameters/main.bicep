targetScope = 'resourceGroup'

@description('Name of the existing App Configuration store.')
param appConfigurationName string

@description('Name of the key-value to create.')
param name string = 'sample-key'

@description('Value of the key-value.')
param value string = 'sample value'

module appConfigurationKeyValue '../../main.bicep' = {
  name: 'appConfigurationKeyValueRequiredParameters'
  params: {
    appConfigurationName: appConfigurationName
    name: name
    value: value
  }
}
