// ========== //
// Parameters //
// ========== //

@description('Optional. The location to deploy resources to')
param location string = resourceGroup().location

var my_tags = {
  env: 'dev'
}

// TEST 1 - minimum parameters
module test1 '../main.bicep' = {
  name: 'kv1'
  params: {
    location: location 
    name: 'kv1'
    tags: my_tags
  }
}
