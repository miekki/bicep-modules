targetScope = 'subscription'

@description('The resource group to contain the App Configuration store.')
param resourceGroupName string = 'rg-appconfiguration-samples'

@description('The Azure region for the resource group and store.')
param location string = 'uksouth'

var tags = {
  environment: 'sample'
}

var storeName = 'appconfig-${uniqueString(subscription().id)}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module appConfiguration '../../main.bicep' = {
  name: 'appConfigurationRequiredParameters'
  scope: resourceGroup
  params: {
    name: storeName
    location: location
    tags: tags
  }
}
