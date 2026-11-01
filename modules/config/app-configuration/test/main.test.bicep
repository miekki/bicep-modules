test minimumConfiguration_defaults '../main.bicep' = {
  params: {
    name: 'appconfig-unit-test-minimum'
    location: 'uksouth'
    tags: {
      environment: 'test'
    }
  }
}

test configurationWithOptionalSettings '../main.bicep' = {
  params: {
    name: 'appconfig-unit-test-optional-settings'
    location: 'uksouth'
    tags: {
      environment: 'test'
    }
    diagnosticSettings: {
      workspaceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.OperationalInsights/workspaces/test'
      logs: [
        {
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
  }
}

test freeSkuDefaults '../main.bicep' = {
  params: {
    name: 'appconfig-unit-test-free'
    location: 'uksouth'
    tags: {
      environment: 'test'
    }
    sku: 'Free'
  }
}

test explicitPublicNetworkAccess '../main.bicep' = {
  params: {
    name: 'appconfig-unit-test-public-access'
    location: 'uksouth'
    tags: {
      environment: 'test'
    }
    publicNetworkAccess: 'Disabled'
  }
}
