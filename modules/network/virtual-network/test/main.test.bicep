// vnet with minial required parameters
module vnet_requiredParameters '../main.bicep' = {
  params: {
    name: 'vnet-minimal'
    location: 'uksouth'
    addressPrefixes: ['10.1.0.0/16']
    tags: {
      env: 'test'
    }
  }
}
