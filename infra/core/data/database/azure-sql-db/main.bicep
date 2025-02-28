param sqlServerName string
param sqlDbName string 
param sqlAdmin string 
@secure()
param sqlPassword string 
param identityName string
param location string 


module azure_sqlDB 'sql-server.bicep' = { 
  name: 'azure_sqlDB'
  params: { 
    sqlServerName:sqlServerName
    sqlDbName:sqlDbName
    sqlAdmin:sqlAdmin
    sqlPassword:sqlPassword
    location:location
  }
}

module azure_sqlDB_roles 'sql-server-roles.bicep' = { 
  name: 'azure_sqlDB_roles'
  params: { 
    sqlServerName:sqlServerName
    sqlDbName:sqlDbName
    identityName:identityName
  }
  dependsOn:[azure_sqlDB]
}
