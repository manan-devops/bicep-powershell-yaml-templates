// A bicep template that deploys app plans and app services with configuration to DEV, QA, and Prod stages

param env string
param location string

var environments = {
  test: {
    api_vnetName: 'INT-Sandbox',
    api_subnetName: 'snet-booking-test',
    api_subnetResourceGroup: 'SandboxNetworking',
    ui_api_vnetName: 'INT-Sandbox',
    ui_api_subnetName: 'snet-booking-ui-api-test',
    ui_api_subnetResourceGroup: 'SandboxNetworking'
  },
  qa: {
    api_vnetName: 'INT-Sandbox',
    api_subnetName: 'snet-booking-qa',
    api_subnetResourceGroup: 'SandboxNetworking',
    ui_api_vnetName: 'INT-Sandbox',
    ui_api_subnetName: 'snet-booking-ui-api-qa',
    ui_api_subnetResourceGroup: 'SandboxNetworking'
  },
  prod: {
    api_vnetName: 'INT-Prod',
    api_subnetName: 'snet-booking-prod',
    api_subnetResourceGroup: 'ProdNetworking',
    ui_api_vnetName: 'INT-Prod',
    ui_api_subnetName: 'snet-booking-ui-api-prod',
    ui_api_subnetResourceGroup: 'ProdNetworking'
  }
}

resource appPlan 'Microsoft.Web/serverFarms@2021-02-01' = {
  name: 'plan-booking-api-${env}'
  params: {
    capacity: 1
    isReserved: false
    kind: 'app, windows'
    name: 'booking-plan-${env}'
    sku: {
      tier: 'P1V3'
      name: 'P1v3'
    }
  }
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: 'appService-booking-api-${env}'
  dependsOn: [
    appPlan
  ]
  params: {
    name: 'app-booking-api-${env}'
    plan: appPlan.outputs.name
    location: location
    vnetName: environments[env].api_vnetName
    subnetName: environments[env].api_subnetName
    subnetResourceGroup: environments[env].api_subnetResourceGroup
    siteConfig: {
      netFrameworkVersion: 'v6.0'
    }
    appSettings: [
      {
        name: 'MY_CUSTOM_SETTING',
        value: 'custom value'
      }
    ]
  }
}
