@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

var uniqueName = 'appconfig-${uniqueString(resourceGroup().id, deployment().name, location)}'

var tags = {
  environment: 'test'
}

module minimumConfiguration '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-minimum'
  params: {
    name: uniqueName
    location: location
    tags: tags
  }
}

module configurationWithKeyValues '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-key-values'
  params: {
    name: '${uniqueName}-kv'
    location: location
    tags: tags
    disableLocalAuth: false
    keyValues: [
      {
        name: 'test-key'
        value: 'test-value'
        contentType: 'text/plain'
        tags: tags
      }
    ]
  }
}
