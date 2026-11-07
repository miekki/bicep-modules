// private DNS zone with minimal required parameters
module privateDnsZone_requiredParameters '../main.bicep' = {
  params: {
    name: 'contoso.local'
    tags: {
      env: 'test'
    }
  }
}
