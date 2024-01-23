// ========== //
// Parameters //
// ========== //

param location string = resourceGroup().location

var uniqueName = uniqueString(resourceGroup().id, deployment().name, location)
var uniqueStoragename = replace(guid(uniqueName), '-', '')
var maxNameLen = 24
var names = {
  test1: {
    storage: take('st1${uniqueStoragename}', maxNameLen)
  }
}
var my_tags = {
  env: 'dev'
}

// TEST 1
module test1 '../main.bicep' = {
  name: 'test1'
  params: {
    location: location
    name: names.test1.storage
    tags: my_tags
  }
}
