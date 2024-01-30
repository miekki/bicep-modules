// ========== //
// Parameters //
// ========== //

param location string = resourceGroup().location
var uniqueName = uniqueString(resourceGroup().id, deployment().name, location)

var my_tags = {
  env: 'dev'
}

// Test 1 - minimum patameters
module test1 '../main.bicep' = {
  name: 'test1'
  params: {
    location: location
    name: uniqueName
    tags: my_tags
    runtimeName: 'dotnet'
    runtimeVersion: '8-lts'
  }
}

// Test 2 - set up production server
module test2 '../main.bicep' = {
  name: 'test2'
  params: {
    location: location
    name: uniqueName
    tags: my_tags
    sku: {
      name: 'S1'
      tier: 'Standard'
      capacity: 2
    }
    reserved: true
    runtimeName: 'node'
    runtimeVersion: '18-lts'
  }
}
