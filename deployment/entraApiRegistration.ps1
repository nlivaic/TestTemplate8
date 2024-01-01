##################################
### Create Azure App Registration
##################################
Param( [string]$displayNameApi = "" )

$appRegistration = az ad app create `
    --display-name $displayNameApi `
    --sign-in-audience AzureADMyOrg `
    --required-resource-accesses "manifest.json"

$appRegistrationResult = ($appRegistration | ConvertFrom-Json)
$appRegistrationResultAppId = $appRegistrationResult.appId
$azAppOID = (az ad app show --id $appRegistrationResultAppId  | ConvertFrom-JSON).id

Write-Host "Created API $displayNameApi with appId: $appRegistrationResultAppId"

##################################
### Expose API
##################################
az ad app update --id $appRegistrationResultAppId --identifier-uris api://$appRegistrationResultAppId
Write-Host "API $displayNameApi exposed"

##################################
###  Add scopes (oauth2Permissions)
##################################
# 0. Setup some basic stuff to work with scopes.
$headerJson = @{
    'Content-Type' = 'application/json'
} | ConvertTo-Json -d 3 -Compress 
$headerJson = $headerJson.replace('"', '\"')
$graphURL="https://graph.microsoft.com/v1.0/applications/$azAppOID"

Write-Host ""
Write-Host "Disabling and deleting existing scopes..."
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
Write-Host "Existing scopes disabled successfully."

# 3. Add new scopes from file oauth2PermissionScopes.json.
Write-Host ""
Write-Host "Creating scopes..."
az rest --method PATCH --uri $graphurl --headers $headerJson --body '@oauth2PermissionScopes.json'
# 4. Re-enable previously disabled scopes.
if ($? -eq $false) {
    Write-Error "Error creating scopes."
    Write-Error "Re-enabling original scopes."
    foreach ($scope in $oauth2PermissionScopesApiOld.oauth2PermissionScopes) {
        Write-Host "`tExisting scope $($scope.value) re-enabled."
        $scope.isEnabled = 'true'
    }
    $bodyOauth2PermissionScopesApiOldJsonEscaped = ($bodyOauth2PermissionScopesApiOld|ConvertTo-Json -d 4 -Compress)
    $bodyOauth2PermissionScopesApiOldJsonEscaped | Out-File -FilePath .\oauth2PermissionScopesOld.json
    az rest --method PATCH --uri $graphurl --headers $headerJson --body '@oauth2PermissionScopesOld.json'
    Remove-Item .\oauth2PermissionScopesOld.json
    Return
}
# 5. If all went well, print confirmation message and list of new scopes.
$appRegistration = az ad app show --id $appRegistrationResultAppId
$appRegistrationResult = ($appRegistration | ConvertFrom-Json)
$oauth2PermissionScopesApi = $appRegistrationResult.api
foreach ($scope in $oauth2PermissionScopesApi.oauth2PermissionScopes) {
    Write-Host "`tScope created: $($scope.value)"
}
Write-Host "Scopes created successfully."

##################################
###  Create a ServicePrincipal for the API App Registration
##################################

az ad app show --id $appRegistrationResultAppId
if ($? -eq $false) {
    az ad sp create --id $appRegistrationResultAppId
    Write-Host "Created Service Principal for API App registration"
} else {
    Write-Host "Service Principal already exists, skipped creation."
}

##################################
###  Return configuration
##################################
[hashtable]$Configuration = @{} 
$Configuration.AuthAuthority = [string]"https://login.microsoftonline.com/$azAppOID/v2.0"
$Configuration.AuthAudience = [string]"api://$appRegistrationResultAppId" 
$Configuration.AuthValidIssuer = [string]"https://sts.windows.net/$azAppOID/" 
return $Configuration
