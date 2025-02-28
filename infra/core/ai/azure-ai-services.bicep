param aiServicesName string
param location string
param identityName string
param customSubdomain string


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing= {
  name: identityName
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServicesName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    customSubDomainName: customSubdomain
    publicNetworkAccess: 'Enabled'
    apiProperties: {
      statisticsEnabled: false
    }
  }
}


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(managedIdentity.id, aiServices.id, 'cognitive-services-openai-contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a001fd3d-188f-4b5d-821b-7da978bf7442') // Cognitive Services OpenAI Contributor role ID
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
  scope:aiServices
}

output aiservicesID string = aiServices.id
output aiservicesTarget string = aiServices.properties.endpoint
output OpenAIEndPoint string = 'https://${customSubdomain}.openai.azure.com'
