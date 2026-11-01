metadata name = 'App Configuration Stores Key Values'
metadata description = 'This module deploys an App Configuration Store Key Value.'

@description('Required. The name of the parent App Configuration store.')
param appConfigurationName string

@description('Required. Name of the key.')
param name string

@description('Required. The value of the key-value.')
param value string

@description('Optional. The content type of the key-values value. Providing a proper content-type can enable transformations of values when they are retrieved by applications.')
param contentType string?

@description('Optional. Tags of the resource.')
param tags object?

// **********************************
// variables
// **********************************

var keyValueProperties = {
  contentType: contentType
  tags: tags
  value: value
}

// **********************************
// Resources
// **********************************

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview' existing = {
  name: appConfigurationName
}

resource keyValues 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-08-01-preview' = {
  name: name
  parent: appConfiguration
  properties: keyValueProperties
}

// **********************************
// Outputs
// **********************************

@description('The name of the key values.')
output name string = keyValues.name

@description('The resource ID of the key values.')
output resourceId string = keyValues.id

assert keyValueValueMatchesInput = keyValueProperties.value == value
assert keyValueContentTypeMatchesInput = keyValueProperties.?contentType == contentType
assert keyValueTagsMatchInput = keyValueProperties.?tags == tags
