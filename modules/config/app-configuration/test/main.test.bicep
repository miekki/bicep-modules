module configurationWithKeyValues '../main.bicep' = {
  params: {
    name: 'appconfig-unit-test-key-values'
    location: 'uksouth'
    tags: {
      environment: 'test'
    }
    disableLocalAuth: false
    diagnosticSettings: {
      workspaceId: resourceId('Microsoft.OperationalInsights/workspaces', 'test-workspace')
      logs: [
        {
          category: null
          categoryGroup: 'audit'
          enabled: true
        }
      ]
    }
    replicaLocations: [
      {
        name: 'secondary'
        replicaLocation: 'eastus2'
      }
    ]
    keyValues: [
      {
        name: 'test-key'
        value: 'test-value'
        contentType: 'text/plain'
        tags: {
          environment: 'test'
        }
      }
    ]
  }
}
