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
    containers: [ 'test2container1', 'test2container2' ]
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
    sku: 'Standard_GRS'

    blobServiceProperties: {
      containerDeleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: true
        days: 90
      }
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: true
        days: 90
      }
    }
  }
}

// TEST 2
module test2 '../main.bicep' = {
  name: 'test2'
  params: {
    location: location
    name: names.test2.storage
    tags: my_tags
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
    blobServiceProperties: {
      containerDeleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: true
        days: 90
      }
      isVersioningEnabled: true
      changeFeed: {
        enabled: true
      }
      lastAccessTimeTrackingPolicy: {
        enable: true
      }
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: true
        days: 90
      }
    }
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
  }
}
