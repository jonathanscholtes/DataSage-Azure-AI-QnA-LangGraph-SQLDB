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
    aiHubDescription: 'Hub for DataSage QnA'
    aiServicesId:aiServices.outputs.aiservicesID
    aiServicesTarget: aiServices.outputs.aiservicesTarget
    keyVaultId: keyVaultId
    location: location
    aiHubFriendlyName: 'Hub for DataSage QnA'
  }
}

module aiProject 'ai-project.bicep' = {
  name: 'aiProject'
  params:{
    aiHubResourceId:aiHub.outputs.aiHubID
    location: location
    aiProjectName: aiProjectName
    aiProjectFriendlyName: 'DataSage QnA Demo Project'
    aiProjectDescription: 'Project for demo DataSage QnA'    
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
