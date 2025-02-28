param sqlServerName string
param sqlDbName string 
param sqlAdmin string 
@secure()
param sqlPassword string 
param location string 

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlPassword
  }
  identity: {
    type: 'SystemAssigned' 
  }
}


resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sqlServer.name}/${sqlDbName}'
  location: location
  properties: {
    createMode: 'Default'
    sampleName: 'AdventureWorksLT' // Specifies the sample database
    autoPauseDelay: 60 // Auto-pause after 60 minutes of inactivity
    minCapacity: 1  // Minimum compute capacity in vCores
  }
  sku: {
    name: 'GP_S_Gen5_2' 
    tier: 'GeneralPurpose'
    family: 'Gen5'
  }
}

resource firewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'AllowAzureServices'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}
