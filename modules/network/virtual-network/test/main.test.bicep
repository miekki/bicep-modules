// ========== //
// Parameters //
// ========== //
@description('Optional. The location to deploy resources to')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
param serviceShort string = 'vnet'

// ============== //
// Test Execution //
// ============== //

// TEST 1 - MIN

module minvnet '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-minvnet'
  params: {
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    name: '${serviceShort}-az-vnet-min-01'
    location: location
    // tags: {
    //   virtualNetworks: 'dev'
    //   env: 'dev'
    //   SLA: '24hours'
    //   department: 'cloud'
    //   businessprocess: 'support'
    // }
  }
}
