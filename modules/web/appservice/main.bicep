metadata name = 'App Service'
metadata description = 'This module deploy App Service with App Service Plan.'
metadata owner = 'MM'

@description('Required. Name of App Service.')
param name string

@description('Required. Location for all resources.')
param location string

@description('Required. Tags of the resource.')
param tags object

// Reference Properties
@description('Optional. Provide Application Insight Name.')
param applicationInsightsName string = ''
@description('Optional. Provide Key Vault Name.')
param keyVaultName string = ''
//@description('Optional. Set to managed Identity if Key Vault Name is provided.')
//param managedIdentity bool = !empty(keyVaultName)

@description('Required. Provide a runtime name from the list.')
@allowed([
  'dotnet', 'dotnetcore', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'
])
param runtimeName string

@description('Required. Provide a runtime version.')
param runtimeVersion string

@description('Optional. Merge runtime name and version.')
param runtimeNameAndVersion string = '${runtimeName}|${runtimeVersion}'

@description('Optional. SKU for the App Service Plan.')
param sku object = {
  name: 'B1'
}

// Microsoft.Web/sites Properties
@description('Optional. Kind of resource')
param kind string = 'app,linux'

@description('Optional. If Linux app service plan true, false otherwise.')
param reserved bool = true

// Microsoft.Web/sites/config
param allowedOrigins array = []
param alwaysOn bool = true
param appCommandLine string = ''
@secure()
param appSettings object = {}
param clientAffinityEnabled bool = false
param enableOryxBuild bool = contains(kind, 'linux')
param functionAppScaleLimit int = -1
param linuxFxVersion string = runtimeNameAndVersion
param minimumElasticInstanceCount int = -1
param numberOfWorkers int = -1
param scmDoBuildDuringDeployment bool = false
param use32BitWorkerProcess bool = false
param ftpsState string = 'FtpsOnly'
param healthCheckPath string = ''

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    reserved: reserved
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      minTlsVersion: '1.2'
      appCommandLine: appCommandLine
      numberOfWorkers: numberOfWorkers != -1 ? numberOfWorkers : null
      minimumElasticInstanceCount: minimumElasticInstanceCount != -1 ? minimumElasticInstanceCount : null
      use32BitWorkerProcess: use32BitWorkerProcess
      functionAppScaleLimit: functionAppScaleLimit != -1 ? functionAppScaleLimit : null
      healthCheckPath: healthCheckPath
      http20Enabled: true
      cors: {
        allowedOrigins: union([ 'https://portal.azure.com', 'https://ms.portal.azure.com' ], allowedOrigins)
      }
    }
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: true
  }

  //identity: { type: managedIdentity ? 'SystemAssigned' : 'None' }
  identity: {
    type: 'SystemAssigned'
  }

  resource configLogs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: { fileSystem: { level: 'Verbose' } }
      detailedErrorMessages: { enabled: true }
      failedRequestsTracing: { enabled: true }
      httpLogs: { fileSystem: { enabled: true, retentionInDays: 1, retentionInMb: 35 } }
    }
  }

  resource basicPublishingCredentialsPoliciesFtp 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource basicPublishingCredentialsPoliciesScm 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }
}

module config './appservice-appsettings/appservice-appsettings.bicep' = if (!empty(appSettings)) {
  name: '${name}-appSettings'
  params: {
    name: appService.name
    appSettings: union(appSettings,
      {
        SCM_DO_BUILD_DURING_DEPLOYMENT: string(scmDoBuildDuringDeployment)
        ENABLE_ORYX_BUILD: string(enableOryxBuild)
      },
      runtimeName == 'python' && appCommandLine == '' ? { PYTHON_ENABLE_GUNICORN_MULTIWORKERS: 'true' } : {},
      !empty(applicationInsightsName) ? { APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString } : {},
      !empty(keyVaultName) ? { AZURE_KEY_VAULT_ENDPOINT: keyVault.properties.vaultUri } : {})
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = if (!(empty(keyVaultName))) {
  name: keyVaultName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsName)) {
  name: applicationInsightsName
}

//output identityPrincipalId string = managedIdentity ? appService.identity.principalId : ''
output identityPrincipalId string = appService.identity.principalId
output appServiceName string = appService.name
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
