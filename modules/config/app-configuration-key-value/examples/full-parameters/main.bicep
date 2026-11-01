targetScope = 'resourceGroup'

@description('Name of the existing App Configuration store.')
param appConfigurationName string

@description('Name of the key-value to create.')
param name string = 'sample-key'

@description('Value of the key-value.')
param value string = 'sample value'

@description('Content type of the key-value.')
param contentType string = 'text/plain'

@description('Tags to set on the key-value.')
param tags object = {
  environment: 'sample'
  owner: 'platform'
}

module appConfigurationKeyValue '../../main.bicep' = {
  name: 'appConfigurationKeyValueFullParameters'
  params: {
    appConfigurationName: appConfigurationName
    name: name
    value: value
    contentType: contentType
    tags: tags
  }
}
