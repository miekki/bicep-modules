@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

@description('Optional. The resource ID of the Log Analytics workspace for diagnostic settings.')
param workspaceId string = resourceId('Microsoft.OperationalInsights/workspaces', 'test-workspace')

var uniqueName = 'appconfig-${uniqueString(resourceGroup().id, deployment().name, location)}'

var tags = {
  environment: 'test'
}

var diagnosticSettings = {
  workspaceId: workspaceId
  logs: [
    {
      category: null
      categoryGroup: 'audit'
      enabled: true
    }
  ]
}

var replicaLocations = [
  {
    name: 'secondary'
    replicaLocation: 'westus2'
  }
]

module minimumConfiguration '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-minimum'
  params: {
    name: uniqueName
    location: location
    tags: tags
    diagnosticSettings: diagnosticSettings
    replicaLocations: replicaLocations
  }
}

module configurationWithKeyValues '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-key-values'
  params: {
    name: '${uniqueName}-kv'
    location: location
    tags: tags
    disableLocalAuth: false
    diagnosticSettings: diagnosticSettings
    replicaLocations: replicaLocations
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
