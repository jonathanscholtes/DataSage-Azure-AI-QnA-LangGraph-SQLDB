targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name used to generate a short unique hash for each resource')
param environmentName string

@minLength(1)
@maxLength(64)
@description('Name used to generate a short unique hash for each resource')
param projectName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('SQL Administrator username')
param sqlAdmin string 

@secure()
@description('SQL Administrator password')
param sqlPassword string


var resourceToken = uniqueString(environmentName,projectName,location,az.subscription().subscriptionId)


resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${projectName}-${environmentName}-${location}-${resourceToken}'
  location: location
}


module security 'core/security/main.bicep' = {
  name: 'security'
  scope: resourceGroup
  params:{
    keyVaultName: 'kv${projectName}${resourceToken}'
    managedIdentityName: 'id-${projectName}-${environmentName}'
    location: location
  }
}

module data 'core/data/main.bicep' = { 
  name: 'data'
  scope: resourceGroup
  params: { 
    projectName:projectName
    environmentName:environmentName
    resourceToken:resourceToken
    location: location
    identityName:security.outputs.managedIdentityName
    sqlAdmin: sqlAdmin
    sqlPassword:sqlPassword
  }
}


module azureai 'core/ai/main.bicep' = {
  name: 'azure-ai'
  scope: resourceGroup
  params: {
    projectName:projectName
    environmentName:environmentName
    resourceToken:resourceToken
    location: location
    keyVaultId: security.outputs.keyVaultID
    identityName:security.outputs.managedIdentityName
  }

}
