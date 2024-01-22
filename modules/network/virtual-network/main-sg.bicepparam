using 'main.bicep'

param name = 'mini-vnet'
param addressPrefixes = ['10.0.0.0/16']
param subnets = [
  {
    name: 'subnet-1'
    addressPrefix: ['10.0.0.0/24']
  } 
  {
    name: 'subnet-2'
    addressPrefix: ['10.0.1.0/24']
  } 
]
param tags = {
  env: 'prod'
}
