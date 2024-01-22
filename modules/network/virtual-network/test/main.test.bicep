// ========== //
// Parameters //
// ========== //

@description('Optional. The location to deploy resources to')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
param serviceShort string = 'vnet'

var my_tags = {
  env: 'dev'
}

// ========== //
// Test Setup //
// ========== //

// General resources
// =================

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-06-01' = {
  name: 'dep-${serviceShort}-az-nsg-x-01'
  location: location
  tags: my_tags
  properties: {
    securityRules: [
      {
        name: 'deny-all'
        properties: {
          priority: 200
          access: 'Deny'
          protocol: 'Tcp'
          direction: 'Outbound'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource routeTable 'Microsoft.Network/routeTables@2023-06-01' = {
  name: 'dep-${serviceShort}-az-rt-x-01'
  location: location
  tags: my_tags
}

// TEST 1 - minimum number of paramaters
module minvnet '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-minvnet'
  params: {
    addressPrefixes: [ '10.0.0.0/16' ]
    name: '${serviceShort}-az-vnet-min-01'
    location: location
    tags: my_tags
  }
}

// TEST 2 - vnet with subnets
module sgvnet '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-sgvnet'

  params: {
    addressPrefixes: [ '10.0.0.0/16' ]
    name: '${serviceShort}-az-vnet-sg-01'
    subnets: [
      {
        name: '${serviceShort}-subnet-001'
        addressPrefix: '10.0.1.0/24'
        //networkSecurityGroupId: networkSecurityGroup.id
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
          {
            service: 'Microsoft.Sql'
          }
        ]
        routeTableId: routeTable.id
      }
      {
        name: '${serviceShort}-subnet-002'
        addressPrefix: '10.0.2.0/24'
        //networkSecurityGroupId: networkSecurityGroup.id
      }
    ]
    location: location
    tags: {
      env: 'dev'
    }
    lock: 'CanNotDelete'
    newOrExistingNSG: 'existing'
    networkSecurityGroupName: networkSecurityGroup.name
  }
}
