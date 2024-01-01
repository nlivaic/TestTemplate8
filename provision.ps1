# Use this file only to provision Azure resources from local.

#az account set -s $SUBSCRIPTION

# Resource group
$jsonResultRg = az deployment sub create --location $env:LOCATION --template-file ./deployment/resource-group.bicep --parameters environment=$env:ENVIRONMENT projectName=$env:PROJECT_NAME location=$env:LOCATION | ConvertFrom-Json
$resourceGroupName = $jsonResultRg.properties.outputs.resourceGroupName.value

# Resources
az deployment group create --resource-group $resourceGroupName --template-file .\deployment\iac.bicep --parameters environment=$env:ENVIRONMENT projectName=$env:PROJECT_NAME db_user=$env:DB_USER db_password=$env:DB_PASSWORD
