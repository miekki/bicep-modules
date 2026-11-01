metadata name = 'Network Interface - Get IP address'
metadata description = 'This module retrieves the private IP address of a network interface.'
metadata owner = 'MM'

@description('Required. The name of the network interface from which you want to get ip address.')
param name string?

@description('Required. The resource ID of the network interface.')
param id string

@description('Optional. The number of IP addresses to retrieve.')
param numberOfIps int = 1

// **********************************
// variables
// **********************************
var nicName = !empty(name) ? name : !empty(id) ? last(split(id, '/')) : null

// **********************************
// Resources
// **********************************
resource nic 'Microsoft.Network/networkInterfaces@2025-05-01' existing = {
  name: nicName ?? ''
}

// **********************************
// Outputs
// **********************************

@description('The first private IP address of the network interface.')
output ip string = nic.properties.ipConfigurations[0].properties.privateIPAddress

@description('An array of private IP addresses of the network interface.')
output ips array = [
  for i in range(0, numberOfIps): {
    ipv4Address: nic.properties.ipConfigurations[?i].?properties.?privateIPAddress
  }
]
