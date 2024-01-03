# Use this file only to provision Azure resources from local.

#az account set -s $SUBSCRIPTION
echo "=============================================================================================================================="
echo $(DB_PASSWORD)
echo "=============================================================================================================================="
# Resource group
$jsonResultRg = az deployment sub create --location $env:LOCATION --template-file ./deployment/resource-group.bicep --parameters environment=$env:ENVIRONMENT projectName=$env:PROJECT_NAME location=$env:LOCATION | ConvertFrom-Json
$resourceGroupName = $jsonResultRg.properties.outputs.resourceGroupName.value
Write-Host "##vso[task.setvariable variable=resourceGroupName;isoutput=true]$resourceGroupName"

# Resources
$jsonResultAll = az deployment group create --resource-group $resourceGroupName --template-file .\deployment\iac.bicep --parameters environment=$env:ENVIRONMENT projectName=$env:PROJECT_NAME db_user=$env:DB_USER db_password=$env:DB_PASSWORD authAuthority='$entraApiConfiguration.AuthAuthority' authAudience='$entraApiConfiguration.AuthAudience' authValidIssuer='$entraApiConfiguration.AuthValidIssuer' --debug | ConvertFrom-Json
$appServiceWebName = $jsonResultAll.properties.outputs.appServiceWebName.value
Write-Host "##vso[task.setvariable variable=appServiceWebName;isoutput=true]$appServiceWebName"
$dbConnection = $jsonResultAll.properties.outputs.dbConnection.value
Write-Host "##vso[task.setvariable variable=dbConnection;isoutput=true]$dbConnection"
