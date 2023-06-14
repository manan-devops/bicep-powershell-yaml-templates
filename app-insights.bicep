/**
Reference:
https://docs.microsoft.com/en-us/azure/azure-monitor/app/resource-manager-app-resource?tabs=bicep
*/
param location string = resourceGroup().location

@description('Name of Application Insights resource.')
param name string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    IngestionMode: 'ApplicationInsights'
  }
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
output connectionString string = appInsights.properties.ConnectionString
