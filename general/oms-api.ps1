$AlertsEnabled = "false"

<#
$OMSResourceGroupId = Get-AutomationVariable -Name 'OMS-Resource-Group-Name'
$OMSWorkspaceName = Get-AutomationVariable -Name 'OMSWorkspaceName'

blah!
$SPNConnection = Get-AutomationConnection -Name 'AzureRunAsSPN'
$SubscriptionID = $SPNConnection.SubscriptionId
$TenantID = $SPNConnection.TenantID
$AzureUserNameForOMS = $SPNConnection.ApplicationId
$AzureUserPasswordForOMS = $SPNConnection.CertificateThumbprint
#>


$OMSResourceGroupId = "mms-eus"
$OMSWorkspaceName = "rabrownlOMS"
$SubscriptionID = "c73e33a6-6855-4123-a017-d95432c640ce"
$TenantID = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$AzureUserNameForOMS = "3fedcd4d-4485-448b-8edf-d814ec80231e"
$AzureUserPasswordForOMS = "1C30GfvuNe8mxh/5gmFgI1yMA9TS6ZB0H+iaK2UvZmU="

#region Get Access Token
$TokenEndpoint = {https://login.windows.net/{0}/oauth2/token} -f $TenantID

$ARMResource = "https://management.core.windows.net/";

$Body = @{
        'resource'= $ARMResource
        'client_id' = $AzureUserNameForOMS
        'grant_type' = 'client_credentials'
        'client_secret' = $AzureUserPasswordForOMS
}

$params = @{
    ContentType = 'application/x-www-form-urlencoded'
    Headers = @{'accept'='application/json'}
    Body = $Body
    Method = 'Post'
    URI = $TokenEndpoint
}

$token = Invoke-RestMethod @params -UseBasicParsing
$Headers = @{'authorization'="Bearer $($Token.access_token)"}   

#endregion

#get all saved searches
$savedSearches = (([string] (Invoke-WebRequest -Method Get -Uri "https://management.azure.com/subscriptions/$SubscriptionID/Resourcegroups/$OMSResourceGroupId/providers/Microsoft.OperationalInsights/workspaces/$OMSWorkspaceName/savedsearches?api-version=2015-03-20" -Headers $Headers -ContentType 'application/x-www-form-urlencoded' -UseBasicParsing).Content) | ConvertFrom-Json).Value.id


#$body = (([string] (Invoke-WebRequest -Method Get -Uri "https://management.azure.com/subscriptions/$SubscriptionID/Resourcegroups/$OMSResourceGroupId/providers/Microsoft.OperationalInsights/workspaces/$OMSWorkspaceName/savedsearches?api-version=2015-03-20" -Headers $Headers -ContentType 'application/x-www-form-urlencoded' -UseBasicParsing).Content)


foreach ($savedSearch in $savedSearches)
{

    #call for schedules associated with the saved searches
    $schedules = (([string] (Invoke-WebRequest -Method Get -Uri "https://management.azure.com/$savedSearch/schedules?api-version=2015-03-20" -Headers $Headers -ContentType 'application/x-www-form-urlencoded' -UseBasicParsing).Content) | ConvertFrom-Json).value

    #check if the saved search has a schedule
    if ($schedules -ne $null)
    {
       # $schedules.value.Properties.Enabled = $AlertsEnabled 

        write-host "schedule 1 is  " $schedules.Properties.Enabled -ForegroundColor Green
       
       
        $scheduleurl = $schedules.id + "?api-version=2015-03-20"

        $body = $schedules | ConvertTo-Json   

        #set new property to sche
        Invoke-WebRequest -Method put -Uri "https://management.azure.com/$scheduleurl" -Headers $Headers -ContentType 'application/json' -Body $Body -UseBasicParsing
     }
     
}

