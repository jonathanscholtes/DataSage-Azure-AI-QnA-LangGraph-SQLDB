param projectName string
param environmentName string
param resourceToken string
param sqlAdmin string
@secure()
param sqlPassword string 
param identityName string
param location string 


var sqlServerName = 'sql-${projectName}-${environmentName}-${resourceToken}'
var sqlDatabaseName = 'sqldb-${projectName}'

module databases 'database/azure-sql-db/main.bicep' = { 
  name:'databases'
  params:{ 
    sqlServerName:sqlServerName
    sqlDbName:sqlDatabaseName
    sqlAdmin:sqlAdmin
    sqlPassword:sqlPassword
    identityName:identityName
    location:location
  }
}

output sqlServerName string = sqlServerName
output sqlDatabaseName string = sqlDatabaseName
