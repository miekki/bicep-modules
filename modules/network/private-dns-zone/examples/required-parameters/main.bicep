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

module privateDnsZone '../../../../../modules/network/private-dns-zone/main.bicep' = {
  name: 'private-dns-zone'
  scope: rg
  params: {
    name: 'contoso.local'
    location: 'global'
    tags: tags
  }
}
