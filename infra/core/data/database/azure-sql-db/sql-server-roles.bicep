
param sqlServerName string
param sqlDbName string 
param identityName string


resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' existing = {
  name: '${sqlServer.name}/${sqlDbName}'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing= {
  name: identityName
}



resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(sqlServer.name, sqlDbName, 'db_contrib')  // Unique name for role assignment
  scope: sqlDatabase
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec') // sql contributor role
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
