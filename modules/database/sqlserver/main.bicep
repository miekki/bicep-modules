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
param databaseName string

@description('Required. The name of the exisiting Key Vault to store connection string.')
param keyVaultName string

@description('Optional. Provide the name of sql admin user name. Default is "sqlAdmin"')
param sqlAdministratorUsername string = 'sqlAdmin'

@description('Optional. Provide the password for sql admin user if left empty it will be generate random password.')
@secure()
param sqlAdministratorPassword string = ''

@description('Optional. Database SKU Name e.g. Basic, Standard (S0-S12), Premium(P1-P15). Defaults is "Basic".')
param databaseSkuName string = 'Basic'

@description('Optional. Database SKU Capacity depends on the sku name for Basic is between 1-5. Defaults is 1.')
param databaseSkuCapacity int = 0

@description('Optional. Database SKU Tier e.g. Basic, Standard, Premium. Defaults is "Basic"')
param databaseSkuTier string = 'Basic'
// @description('Optional. Provide the Log Analytics Workspace ID to store logs.')
// param workspaceId string = ''

@description('Optional. Provide VNet subnet id to protect the database.')
param sqlServerSubnetId string = ''

@description('Optional. Provide a key name in Key Vault where the connection string will be saved. Default is "AZURE-SQL-CONNECTION-STRING"')
param connectionStringKey string = 'AZURE-SQL-CONNECTION-STRING'

param guidValue string = newGuid()

var adminPassword = !empty(sqlAdministratorPassword) ? sqlAdministratorPassword : 'P${toUpper(uniqueString(resourceGroup().id))}-${guidValue}'

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
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
    name: databaseName
    location: location
    sku: {
      name: databaseSkuName
      capacity: databaseSkuCapacity == 0 ? null : databaseSkuCapacity
      tier: databaseSkuTier
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

@description('The resource ID of the SQL server.')
output resourceId string = sqlServer.id
