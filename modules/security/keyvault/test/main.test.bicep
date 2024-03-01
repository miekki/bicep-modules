// ========== //
// Parameters //
// ========== //

@description('Optional. The location to deploy resources to')
param location string = resourceGroup().location

var my_tags = {
  env: 'dev'
}

module vNet '../../../network/virtual-network/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vnet'
  params: {
    name: 'az-vnet-01'
    addressPrefixes: [ '10.0.0.0/16' ]
    location: location
    tags: my_tags
    subnets: [
      {
        name: 'frontend-subnet-01'
        addressPrefix: '10.0.1.0/24'
        networkSecurityGroupId: '/subscriptions/111111-1111-1111-1111-111111111111/resourceGroups/validation-rg/providers/Microsoft.Network/networkSecurityGroups/az-nsg-01'
      }
      {
        name: 'backend-subnet-01'
        addressPrefix: '10.0.2.0/24'
        networkSecurityGroupId: '/subscriptions/111111-1111-1111-1111-111111111111/resourceGroups/validation-rg/providers/Microsoft.Network/networkSecurityGroups/az-nsg-01'
      }

    ]
  }
}

// TEST 1 - minimum parameters
module test1 '../main.bicep' = {
  name: 'kv1'
  params: {
    location: location
    workspaceId: '11'
    name: 'kv1'
    tags: my_tags
  }
}

// TEST 2 - key vault part of the network
module test2 '../main.bicep' = {
  name: 'kv2'
  params: {
    location: location
    workspaceId: '11'
    name: 'kv2'
    tags: my_tags

    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipAllowlist: [
        '127.0.0.1'
      ]
      //subnetIds: vNet.outputs.subnetResourceIds
      subnetIds: [
        '/subscriptions/111111-1111-1111-1111-111111111111/resourceGroups/validation-rg/providers/Microsoft.Network/networkSecurityGroups/az-nsg-01'
      ]
    }

  }
}
