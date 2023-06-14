param env string
@secure()
param ddApiKey string
param location string
var cosmosDbKey = listKeys(resourceId(resourceGroup().name,'Microsoft.DocumentDB/databaseAccounts','cosmos-booking-cus-${env}'),'2022-05-15').primaryMasterKey

var environments = {
  test: {
    api_vnetName: 'INT-Sandbox'
    api_subnetName: 'snet-booking-test'
    api_subnetResourceGroup: 'SandboxNetworking'
    ui_api_vnetName: 'INT-Sandbox'
    ui_api_subnetName: 'snet-booking-ui-api-test'
    ui_api_subnetResourceGroup: 'SandboxNetworking'
  }
  qa: {
    api_vnetName: 'INT-Sandbox'
    api_subnetName: 'snet-booking-qa'
    api_subnetResourceGroup: 'SandboxNetworking'
    ui_api_vnetName: 'INT-Sandbox'
    ui_api_subnetName: 'snet-booking-ui-api-qa'
    ui_api_subnetResourceGroup: 'SandboxNetworking'
  }
  prod: {
    api_vnetName: 'INT-Prod'
    api_subnetName: 'snet-booking-prod'
    api_subnetResourceGroup: 'ProdNetworking'
    ui_api_vnetName: 'INT-Prod'
    ui_api_subnetName: 'snet-booking-ui-api-prod'
    ui_api_subnetResourceGroup: 'ProdNetworking'
  }
}

resource appPlan 'Microsoft.Web/serverFarms@2021-02-01' = {
  name: 'plan-booking-api-${env}'
  params: {
    capacity: 1
    isReserved: false
    planKind: 'app,windows'
    planName: 'booking-plan-${env}'
    sku: 'P1v3'
    skuCode: 'B1'
  }
}


resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'bookingApiAppInsights'
  params: {
    name: 'appi-booking-${env}'
    location: location
  }
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: 'appService-booking-api-${env}'
  dependsOn: [
    appPlan
    appInsights
  ]
  params: {
    appServiceName: 'app-booking-api-${env}'
    appServicePlanName: appPlan.outputs.appPlanName
    datadogAPIKey: ''
    datadogServiceName: 'booking API ${env}'  
    isAppServiceAlwaysOn: false
    isAppServicePublic: true
    location: location
    isVnetIntegrated: true
    vnetName: environments[env].api_vnetName
    subnetName: environments[env].api_subnetName
    subnetResourceGroup: environments[env].api_subnetResourceGroup
    infraOnlyAppSettings: {
      WEBSITE_RUN_FROM_PACKAGE: 1
      DD_API_KEY: ddApiKey
      APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.outputs.instrumentationKey
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.outputs.connectionString
      Cosmos__endpointUrl: 'https://cosmos-booking-cus-${env}.documents.azure.com:443/'
      Cosmos__key: cosmosDbKey
      Serilog__WriteTo__1__Args__apiKey: ddApiKey
      Serilog__WriteTo__1__Args__source: 'booking API ${env}'
      Serilog__WriteTo__1__Args__service: 'booking API ${env}'
    }
    siteConfig: {
      netFrameworkVersion: 'v6.0'
    }
  }
}
