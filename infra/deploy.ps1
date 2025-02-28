param (
    [string]$Subscription,
    [string]$Location = "eastus2",
    [string]$SQLAdminUser = "sqlAdminUser",
    [string]$SQLPassword = ""
)


# Variables
$projectName = "agentqna"
$environmentName = "demo"
$templateFile = "main.bicep"
$deploymentName = "agentdeployment-$Location"

# Clear account context and configure Azure CLI settings
az account clear
az config set core.enable_broker_on_windows=false
az config set core.login_experience_v2=off

# Login to Azure
az login 
az account set --subscription $Subscription


# Start the deployment
$deploymentOutput = az deployment sub create `
    --name $deploymentName `
    --location $Location `
    --template-file $templateFile `
    --parameters `
        environmentName=$environmentName `
        projectName=$projectName `
        location=$Location `
        sqlAdmin=$SQLAdminUser `
        sqlPassword=$SQLPassword `
    --query "properties.outputs"


Write-Output "Deployment Complete"