targetScope = 'subscription'

param location string = 'uksouth'

var tags = {
  environment: 'dev'
}

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-private-dns-zone'
  location: location
  tags: tags
}

resource vnetRg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-private-dns-zone-vnet'
  location: location
  tags: tags
}

module vnet '../../../../../modules/network/virtual-network/main.bicep' = {
  name: 'hub-vnet'
  scope: vnetRg
  params: {
    name: 'hub-vnet'
    location: location
    tags: tags
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: 'default'
        addressPrefix: '10.0.0.0/24'
      }
    ]
  }
}

module privateDnsZone '../../../../../modules/network/private-dns-zone/main.bicep' = {
  name: 'private-dns-zone'
  scope: rg
  params: {
    name: 'contoso.local'
    location: 'global'
    tags: tags
    virtualNetworkLinks: [
      {
        name: 'hub-vnet-link'
        virtualNetworkResourceId: vnet.outputs.resourceId
        registrationEnabled: false
        resolutionPolicy: 'NxDomainRedirect'
      }
    ]
    a: [
      {
        name: 'api'
        ttl: 300
        aRecords: [
          {
            ipv4Address: '10.0.0.9'
          }
        ]
      }
    ]
    lock: {
      name: 'lock-name'
      kind: 'CanNotDelete'
      notes: 'lock-notes'
    }
  }
}
