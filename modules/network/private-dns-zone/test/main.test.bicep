// private DNS zone with minimal required parameters
test privateDnsZone_requiredParameters '../main.bicep' = {
  params: {
    name: 'contoso.local'
    tags: {
      env: 'test'
    }
  }
}

// The local evaluator cannot evaluate copyIndex expressions emitted for array-backed resources.
// Those optional inputs are compile-checked, while this case covers the lock override.
test privateDnsZone_lockOverride '../main.bicep' = {
  params: {
    name: 'contoso.local'
    location: 'global'
    tags: {
      env: 'dev'
    }
    lock: {
      name: 'lock-name'
      kind: 'CanNotDelete'
      notes: 'lock-notes'
    }
  }
}

test virtualNetworkLink_resolutionPolicyDefault '../../internal-modules/private-dns-zone-virtual-network-link/main.bicep' = {
  params: {
    privateDnsZoneName: 'contoso.local'
    virtualNetworkResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test'
    tags: {
      env: 'test'
    }
  }
}

test virtualNetworkLink_resolutionPolicyOverride '../../internal-modules/private-dns-zone-virtual-network-link/main.bicep' = {
  params: {
    privateDnsZoneName: 'contoso.local'
    virtualNetworkResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test'
    tags: {
      env: 'test'
    }
    resolutionPolicy: 'NxDomainRedirect'
  }
}
