
#Check the Login Status
$LoginStatus = m365 status

if($LoginStatus -Match "Logged out"){
    #Exiting the execution
    exit;    
}

$webURL = "https://aum365.sharepoint.com/sites/M365CLI"
$listName = "O365 Health Status"
$workLoads = m365 tenant status list --query "value[?Status != 'ServiceOperational']"  --output json  | ConvertFrom-Json
$currentOutageServices = (m365 spo listitem list --webUrl $webURL --title $listName --fields "Title, Workload, Id"  --output json).Replace("ID", "_ID") | ConvertFrom-Json

#Adding items if any of the workload is not availble
$workLoads | ?{$_.Workload -notin $currentOutageServices.Workload} | %{ $AddedItem = m365 spo listitem add --webUrl $webURL --listTitle $listName --contentType Item --Title $_.WorkloadDisplayName --Workload $_.Workload --FirstIdentifiedDate (Get-Date -Date $_.StatusTime -Format "MM/dd/yyyy HH:mm") --WorkflowJSONData (Out-String -InputObject $_ -Width 100) }

 #Updating the status to IsInOutage to NO the list item if the service is back to normal
$currentOutageServices | ?{$_.Workload -notin $workLoads.Workload} | %{ $UpdatedWorkflod = m365 spo listitem set --webUrl $webURL --listTitle $listName --contentType Item --id  $_.Id --StillinOutage "false" }

