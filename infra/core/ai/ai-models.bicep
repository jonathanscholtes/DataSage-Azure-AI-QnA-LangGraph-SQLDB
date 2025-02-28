
@description('AI Service name')
param aiServicesName string



resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName

}


resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: aiServices
  name: 'gpt-4o'
  sku: {
    capacity: 10
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-11-20'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
    raiPolicyName: 'Microsoft.DefaultV2'
    
  }
}

resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: aiServices
  name: 'text-embedding'
  sku: {
    capacity: 120
    name: 'Standard'
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
    raiPolicyName: 'Microsoft.DefaultV2'
    
  }
  dependsOn: [gptDeployment]
}
