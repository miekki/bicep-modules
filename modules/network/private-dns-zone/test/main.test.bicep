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
