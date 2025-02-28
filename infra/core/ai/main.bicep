param projectName string
param environmentName string
param resourceToken string
param location string
param identityName string


@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string


var aiServicesName  = 'ais-${projectName}-${environmentName}-${resourceToken}'
var aiProjectName  = 'prj-${projectName}-${environmentName}-${resourceToken}'

module aiServices 'azure-ai-services.bicep' = {
  name: 'aiServices'
  params: {
    aiServicesName: aiServicesName
    location: location
    identityName: identityName
    customSubdomain: 'openai-app-${resourceToken}'
  }
}

module aiHub 'ai-hub.bicep' = {
  name: 'aihub'
  params:{
    aiHubName: 'hub-${projectName}-${environmentName}-${resourceToken}'
    aiHubDescription: 'Hub for demo deepseek knowledge graph'
    aiServicesId:aiServices.outputs.aiservicesID
    aiServicesTarget: aiServices.outputs.aiservicesTarget
    keyVaultId: keyVaultId
    location: location
    aiHubFriendlyName: 'AI Game Graph Demo Hub'
  }
}

module aiProject 'ai-project.bicep' = {
  name: 'aiProject'
  params:{
    aiHubResourceId:aiHub.outputs.aiHubID
    location: location
    aiProjectName: aiProjectName
    aiProjectFriendlyName: 'AI Game Graph Demo Project'
    aiProjectDescription: 'Project for demo game knowledge graph'    
  }
}

module aiModels 'ai-models.bicep' = {
  name:'aiModels'
  params:{
     aiServicesName:aiServicesName
  }
  dependsOn:[aiServices,aiProject]
}


output aiservicesTarget string = aiServices.outputs.aiservicesTarget
output OpenAIEndPoint string = aiServices.outputs.OpenAIEndPoint
