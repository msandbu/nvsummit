$TenantID = ‘tenantid' #The Directory ID from Azure AD
$ClientID = ‘clientid' #The Application ID of the registered app
$ClientSecret = ‘clientsecret' #The secret key of the registered app
# ------------------------------------------------------

$body = @{grant_type="client_credentials";resource="https://manage.office.com";client_id=$ClientID;client_secret=$ClientSecret }
$oauth = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$($tenantID)/oauth2/token?api-version=1.0" -Body $body
$token = @{'Authorization' = "$($oauth.token_type) $($oauth.access_token)" }
# ------------------------------------------------------

$ServiceStatus = Invoke-RestMethod -Uri "https://manage.office.com/api/v1.0/$($TenantID)/ServiceComms/CurrentStatus" -Headers $token -Method Get -Verbose
$ServiceStatus.Value | Format-Table IncidentIDs,WorkloadDisplayName,Status 
