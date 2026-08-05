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
