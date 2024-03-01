metadata name = 'SQL Server'
metadata description = 'This module deploy Azure SQL Server'
metadata owner = 'MM'

@description('Required. The SQL Server Name.')
param sqlServerName string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags of the resource.')
param tags object

@description('Required. The SQL Server Database Name.')
param sqlDatabaseName string

@description('Required. The name of the exisiting Key Vault to store connection string.')
param keyVaultName string

@description('Optional. Provide the name of sql admin user name.')
param sqlAdministratorUsername string = 'sqlAdmin'

@description('Optional. Provide the password for sql admin user.')
@secure()
param sqlAdministratorPassword string = ''

param skuName string = 'B1'
param skuCapacity int = 1
param skuTier string = 'Basic'
// @description('Optional. Provide the Log Analytics Workspace ID to store logs.')
// param workspaceId string = ''

@description('Optional. Provide VNet subnet id to protect the database.')
param sqlServerSubnetId string = ''

param connectionStringKey string = 'AZURE-SQL-CONNECTION-STRING'

param guidValue string = newGuid()

var adminPassword = empty(sqlAdministratorPassword) ? sqlAdministratorPassword : '${toUpper(uniqueString(resourceGroup().id))}-${guidValue}'

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.3'
    publicNetworkAccess: 'Enabled'
    administratorLogin: sqlAdministratorUsername
    administratorLoginPassword: adminPassword
  }
  resource vnetRule 'virtualNetworkRules' = if (!empty(sqlServerSubnetId)) {
    name: sqlServerName
    properties: {
      virtualNetworkSubnetId: sqlServerSubnetId
    }
  }

  resource sqlDatabase 'databases' = {
    name: sqlDatabaseName
    location: location
    sku: {
      name: skuName
      capacity: skuCapacity
      tier: skuTier
    }
  }

  resource firewall 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

// resource vnetRule 'Microsoft.Sql/servers/virtualNetworkRules@2023-05-01-preview' = if (!empty(sqlServerSubnetId)) {
//   name: sqlServerName
//   properties: {
//     virtualNetworkSubnetId: sqlServerSubnetId
//   }
// }

// resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
//   parent: sqlServer
//   name: sqlDatabaseName
//   location: location
//   sku: {
//     name: skuName
//     capacity: skuCapacity
//     tier: skuTier
//   }
// }

// resource firewall 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
//   parent: sqlServer
//   name: 'AllowAllWindowsAzureIps'
//   properties: {
//     startIpAddress: '0.0.0.0'
//     endIpAddress: '0.0.0.0'
//   }
// }

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: connectionStringKey
  properties: {
    value: 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Database=${sqlServer::sqlDatabase.name}; User=${sqlAdministratorUsername}; Password=${adminPassword};'
  }
}
