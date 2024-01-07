# Use this file only to provision Azure resources from local.
param ($location, $environment, $projectName, $dbUser, $dbPassword)
#az account set -s $SUBSCRIPTION
Write-Host "------ Azure AD Provisioning START ------"
$entraApiConfiguration = .\deployment\entraApiRegistration.ps1 $projectName
Write-Host "------ Azure AD Provisioning END ------"

# Resource group
Write-Host "------ Create Resource Group START ------"
$jsonResultRg = az deployment sub create --location $location --template-file ./deployment/resource-group.bicep --parameters environment=$environment projectName=$projectName location=$location | ConvertFrom-Json
$resourceGroupName = $jsonResultRg.properties.outputs.resourceGroupName.value
Write-Host "##vso[task.setvariable variable=resourceGroupName;isoutput=true]$resourceGroupName"
Write-Host "------ Create Resource Group END ------"

# Resources
Write-Host "------ Create Resources START ------"
$jsonResultAll = az deployment group create --resource-group $resourceGroupName --template-file .\deployment\iac.bicep --parameters environment=$environment projectName=$projectName db_user=$dbUser db_password=$dbPassword authAuthority=$entraApiConfiguration.AuthAuthority authAudience=$entraApiConfiguration.AuthAudience authValidIssuer=$entraApiConfiguration.AuthValidIssuer | ConvertFrom-Json
$appServiceWebName = $jsonResultAll.properties.outputs.appServiceWebName.value
Write-Host "##vso[task.setvariable variable=appServiceWebName;isoutput=true]$appServiceWebName"
$dbConnection = $jsonResultAll.properties.outputs.dbConnection.value
Write-Host "##vso[task.setvariable variable=dbConnection;isoutput=true]$dbConnection"
Write-Host "------ Create Resources END ------"
