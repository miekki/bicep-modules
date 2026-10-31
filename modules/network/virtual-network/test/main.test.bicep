// vnet with minial required parameters
test vnet_requiredParameters '../main.bicep' = {
  params: {
    name: 'vnet-minimal'
    location: 'uksouth'
    addressPrefixes: ['10.1.0.0/16']
    tags: {
      env: 'test'
    }
  }
}

// vnet with all parameters
test vnet_fullParameters '../main.bicep' = {
  params: {
    name: 'vnet-full'
    location: 'uksouth'
    addressPrefixes: ['10.0.0.0/16']
    tags: {
      env: 'dev'
    }
    subnets: [
      {
        name: 'subnet-app'
        addressPrefix: '10.0.1.0/24'
        networkSecurityGroup: {
          id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg-test'
        }
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
        ]
        routeTable: {
          id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/routeTables/rt-test'
        }
      }
      {
        name: 'subnet-data'
        addressPrefix: '10.0.2.0/24'
      }
    ]
    lock: {
      name: 'lock-name'
      kind: 'CanNotDelete'
      notes: 'lock-notes'
    }
  }
}
