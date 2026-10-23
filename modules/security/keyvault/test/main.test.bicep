// key vault with monimal required parameters
test kv_requiredParameters '../main.bicep' = {
  params: {
    name: 'kv-minimal'
    location: 'uksouth'
    tags: {
      env: 'test'
    }
  }
}

test kv_fullParameters '../main.bicep' = {
  params: {
    name: 'kv-full'
    location: 'uksouth'
    tags: {
      env: 'dev'
    }
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipAllowlist: ['10.0.0.1']
      subnetIds: [
        '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test'
      ]
    }
    lock: {
      name: 'lock-name'
      kind: 'CanNotDelete'
      notes: 'lock-notes'
    }
  }
}
