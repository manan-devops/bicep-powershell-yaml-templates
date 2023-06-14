param cosmosDbAccountName string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-08-15' = {
  name: cosmosDbAccountName
  location: resourceGroup().location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
  }
}

output cosmosDbAccountResourceId string = cosmosDbAccount.id


// Imported params
param environment  string
param appName  string
param includeNetworkSecurity  bool
param cosmosDBAccountName string
param cosmosDBName string
param cosmosDBContainers_Employees string

param region string = resourceGroup().location
param subnetName  string
param virtualNetworkName  string
param apiAppPrincipalId  string

// Local params
param privateEndpointName string = 'pe-cosmos-${appName}-${environment}'
param tags object = {
  'deploymentGroup':'cosmosdb'
}

var roleDefinitionId = guid('sql-role-definition-', apiAppPrincipalId, cosmosDbAccount.id)
var roleAssignmentId = guid(roleDefinitionId, apiAppPrincipalId, cosmosDbAccount.id)
var roleDefinitionName = 'Cosmos_ReadWrite'
var dataActions = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]
var privateDnsZoneName = 'privatelink.documents.azure.com'

// Deployments - Coosmos DB Resources 
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: cosmosDBAccountName
  tags:tags
  location: region
  properties:{
    databaseAccountOfferType:'Standard'
    enableAutomaticFailover:false
    enableMultipleWriteLocations:false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: region
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  name: '${cosmosDbAccount.name}/${cosmosDBName}'
  tags: tags
  dependsOn: [
    cosmosDbAccount
  ]
  properties:{
    resource:{
      id:'db-${appName}'
    }
  }
}

resource employeesContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  name:'${cosmosDb.name}/${cosmosDBContainers_Employees}'
  tags:tags
  dependsOn: [
    cosmosDbAccount
    cosmosDb
  ]
  properties:{
    resource:{
      id: cosmosDBContainers_Employees
      partitionKey:{
        paths:[
          '/id'
        ]
      }
    }
  }
}
