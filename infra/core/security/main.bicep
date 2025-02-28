param keyVaultName string
param managedIdentityName string
param location string


module managedIdentity 'managed-identity.bicep' = {
  name: 'managed-identity'
  params: {
    name: managedIdentityName
    location: location
  }
}


module keyVault 'keyvault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    keyVaultName: keyVaultName
  }
}



output managedIdentityName string = managedIdentity.outputs.managedIdentityName
output keyVaultID string = keyVault.outputs.keyVaultId
output keyVaultName string = keyVaultName
output keyVaultUri string = keyVault.outputs.keyVaultUri

