using 'main.bicep'

param name = 'mini-vnet'
param addressPrefixes = ['10.0.0.0/16']
param tags = {
  env: 'prod'
}
