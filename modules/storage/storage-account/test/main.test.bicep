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
  test2: {
    storage: take('st2${uniqueStoragename}', maxNameLen)
    containers: ['test2container1', 'test2container2']
    queues: ['test2queue1', 'test2queue2']
    tables: ['Test2Table1', 'Test2Table2']
  }
  test3: {
    storage: take('st3${uniqueStoragename}', maxNameLen)
  }
}
var my_tags = {
  env: 'dev'
}

// TEST 1 - minimum parameters
module test1 '../main.bicep' = {
  name: 'test1'
  params: {
    location: location
    name: names.test1.storage
    tags: my_tags
    sku: 'Standard_GRS'
    networkAcls: {
      defaultAction: 'Deny'
      resourceAccessRules: [
        {
          resourceId: resourceId('Microsoft.Web/sites', 'example')
          tenantId: tenant().tenantId
        }
      ]
    }
  }
}

// TEST 2 - storage with blobs
module test2 '../main.bicep' = {
  name: 'test2'
  params: {
    location: location
    name: names.test2.storage
    tags: my_tags

    blobContainers: [
      {
        name: names.test2.containers[0]
      }
      {
        name: names.test2.containers[1]
        properties: {
          publicAccess: 'None'
        }
      }
    ]
    queues: [
      {
        name: names.test2.queues[0]
      }
      {
        name: names.test2.queues[1]
      }
    ]
    tables: [
      {
        name: names.test2.tables[0]
      }
      {
        name: names.test2.tables[1]
      }
    ]
  }
}

// TEST 3 - storage with a private endpoint
module test3 '../main.bicep' = {
  name: 'test3'
  params: {
    location: location
    name: names.test3.storage
    tags: my_tags
    privateEndpoints: [
      {
        service: 'blob'
        subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', 'test-vnet', 'private-endpoints')
        location: location
      }
    ]
  }
}
