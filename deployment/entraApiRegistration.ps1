##################################
### Create Azure App Registration
##################################
Param( [string]$projectName = "" )

$displayNameApi = "$($projectName)Api"

Write-Host "--- Create Azure App Registration - START ---" -ForegroundColor Yellow
Write-Host "displayNameApi: $displayNameApi" -ForegroundColor Green
$appRegistration = az ad app create `
    --display-name $displayNameApi `
    --sign-in-audience AzureADMyOrg `
    --required-resource-accesses "deployment/manifest.json"

$appRegistrationResult = ($appRegistration | ConvertFrom-Json)
$appRegistrationResultAppId = $appRegistrationResult.appId
$azAppOID = (az ad app show --id $appRegistrationResultAppId  | ConvertFrom-JSON).id

Write-Host "Created API $displayNameApi with appId: $appRegistrationResultAppId" -ForegroundColor Green
Write-Host "--- Create Azure App Registration - END ---" -ForegroundColor Yellow

##################################
### Expose API
##################################
Write-Host "--- Expose API - START ---" -ForegroundColor Yellow
az ad app update --id $appRegistrationResultAppId --identifier-uris api://$appRegistrationResultAppId
Write-Host "API $displayNameApi exposed" -ForegroundColor Green
Write-Host "--- Expose API - END ---" -ForegroundColor Yellow

##################################
###  Add scopes (oauth2Permissions)
##################################
Write-Host "--- Add scopes - START ---" -ForegroundColor Yellow
# 0. Setup some basic stuff to work with scopes.
$headerJson = @{
    'Content-Type' = 'application/json'
} | ConvertTo-Json -d 3 -Compress 
$headerJson = $headerJson.replace('"', '\"')
$graphURL="https://graph.microsoft.com/v1.0/applications/$azAppOID"

Write-Host ""
Write-Host "Disabling existing scopes..." -ForegroundColor Green
# 1. Read existing scopes.
$oauth2PermissionScopesApiOld = $appRegistrationResult.api
# 2. Disable scopes, because we want to provision from a list.
foreach ($scope in $oauth2PermissionScopesApiOld.oauth2PermissionScopes) {
    Write-Host "`tExisting scope $($scope.value) disabled."
    $scope.isEnabled = 'false'
}
$bodyOauth2PermissionScopesApiOld = @{
    api = $appRegistrationResult.api
}
$bodyOauth2PermissionScopesApiOldJsonEscaped = ($bodyOauth2PermissionScopesApiOld|ConvertTo-Json -d 4 -Compress)
$bodyOauth2PermissionScopesApiOldJsonEscaped | Out-File -FilePath .\oauth2PermissionScopesOld.json
az rest --method PATCH --uri $graphurl --headers $headerJson --body '@oauth2PermissionScopesOld.json'
Remove-Item .\oauth2PermissionScopesOld.json
Write-Host "Existing scopes disabled successfully." -ForegroundColor Green

# 3. Add new scopes from file oauth2PermissionScopes.json.
Write-Host ""
Write-Host "Creating scopes..." -ForegroundColor Green
az rest --method PATCH --uri $graphurl --headers $headerJson --body '@deployment/oauth2PermissionScopes.json'
# 4. Re-enable previously disabled scopes.
if ($? -eq $false) {
    Write-Error "Error creating scopes." -ForegroundColor Red
    Write-Error "Re-enabling original scopes." -ForegroundColor Red
    foreach ($scope in $oauth2PermissionScopesApiOld.oauth2PermissionScopes) {
        Write-Host "`tExisting scope $($scope.value) re-enabled." -ForegroundColor Red
        $scope.isEnabled = 'true'
    }
    $bodyOauth2PermissionScopesApiOldJsonEscaped = ($bodyOauth2PermissionScopesApiOld|ConvertTo-Json -d 4 -Compress)
    $bodyOauth2PermissionScopesApiOldJsonEscaped | Out-File -FilePath .\oauth2PermissionScopesOld.json
    az rest --method PATCH --uri $graphurl --headers $headerJson --body '@oauth2PermissionScopesOld.json'
    Remove-Item .\oauth2PermissionScopesOld.json
    Write-Host "--- Add scopes - END (Error) ---" -ForegroundColor Red
    Return
}
# 5. If all went well, print confirmation message and list of new scopes.
$appRegistration = az ad app show --id $appRegistrationResultAppId
$appRegistrationResult = ($appRegistration | ConvertFrom-Json)
$oauth2PermissionScopesApi = $appRegistrationResult.api
foreach ($scope in $oauth2PermissionScopesApi.oauth2PermissionScopes) {
    Write-Host "`tScope created: $($scope.value)" -ForegroundColor Green
}
Write-Host "Scopes created successfully." -ForegroundColor Green
Write-Host "--- Add scopes - END ---" -ForegroundColor Yellow

Write-Host ""
Write-Host "Registered App details:" -ForegroundColor Green
Write-Host $appRegistration -ForegroundColor Green

##################################
###  Create a ServicePrincipal for the API App Registration
##################################
Write-Host "--- Create a ServicePrincipal - START ---" -ForegroundColor Yellow

$createdSp = az ad sp show --id $appRegistrationResultAppId
if ($? -eq $false) {
    $createdSp = az ad sp create --id $appRegistrationResultAppId
    Write-Host "Created Service Principal for API App registration" -ForegroundColor Green
} else {
    Write-Host "Service Principal already exists, skipped creation." -ForegroundColor Green
}
Write-Host "Service principal details:" -ForegroundColor Green
Write-Host $createdSp -ForegroundColor Green
Write-Host "--- Create a ServicePrincipal - END ---" -ForegroundColor Yellow

##################################
###  Return configuration
##################################
Write-Host "##vso[task.setvariable variable=authAuthority;isoutput=true]https://login.microsoftonline.com/$azAppOID/v2.0"
Write-Host "##vso[task.setvariable variable=authAudience;isoutput=true]api://$appRegistrationResultAppId"
Write-Host "##vso[task.setvariable variable=authValidIssuer;isoutput=true]https://sts.windows.net/$azAppOID/"
