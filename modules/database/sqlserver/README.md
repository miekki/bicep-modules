# SQL Server

This module deploys Azure SQL Server.

## Details

Use this module within other Bicep templates to simplify the usage of a SQL Server.

## Parameters

| Name                       |   Type   | Required | Description                                                                                                                   |
| :------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------- |
| `sqlServerName`            | `string` |   Yes    | Required. The SQL Server Name                                                                                                 |
| `location`                 | `string` |   Yes    | Required. Location name for the resource. default to resource group location                                                  |
| `tags`                     | `object` |   Yes    | Required. Tags of the resources                                                                                               |
| `sqlDatabaseName`          | `string` |   Yes    | Required. The SQL Server Database Name                                                                                        |
| `keyVaultName`             | `string` |   Yes    | Required. The name of the exisiting Key Vault to store connection string                                                      |
| `sqlAdministratorUsername` | `string` |    No    | Optional. Provide the name of sql admin user name                                                                             |
| `sqlAdministratorPassword` | `string` |    No    | Optional. Provide the password for sql admin user if left empty it will be generate random password                           |
| `skuName`                  | `string` |    No    | Optional. Database SKU Name e.g. Basic, Standard (S0-S12), Premium(P1-P15). Defaults is Basic.                                |
| `skuCapacity`              | `string` |    No    | Optional. Database SKU Capacity depends on the sku name for Basic is between 1-5. Defaults is 1                               |
| `skuTier`                  | `string` |    No    | Optional. Database SKU Tier e.g. Basic, Standard, Premium. Defaults is Basic                                                  |
| `sqlServerSubnetId`        | `string` |    No    | Optional. Provide VNet subnet id to protect the database                                                                      |
| `connectionStringKey`      | `string` |    No    | Optional. Provide a key name in Key Vault where the connection string will be saved. Default is "AZURE-SQL-CONNECTION-STRING" |

## Outputs

| Name         |   Type   | Description                       |
| :----------- | :------: | :-------------------------------- |
| `resourceId` | `string` | The resource ID of the SQL server |

## Examples

### Examples 1

The example how to deploy the SQL Server using the minimum required oarameters.

```bicep
module sql 'br:mmbicepmoduleregistry.azurecr.io/sqlserver"1.0.2' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-sql'
  params: {
    keyVaultName: 'my-kv-name'
    location: 'uksouth'
    databaseName: 'my-db-name'
    sqlServerName: 'my-sql-server-name'
    tags: {
        environment: 'production'
    }
  }
}
```
