
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

Foreach ($workload in $workLoads){
    if($workload.Workload -notin $currentOutageServices.Workload){
        $AddedItem = m365 spo listitem add --webUrl $webURL --listTitle $listName --contentType Item --Title $workload.WorkloadDisplayName --Workload $workload.Workload --FirstIdentifiedDate (Get-Date -Date $workload.StatusTime -Format "MM/dd/yyyy HH:mm") --WorkflowJSONData (Out-String -InputObject $workload -Width 100)

        #Send notification using CLI Commands
        m365 outlook mail send --to "arjun@aum365.onmicrosoft.com" --subject "Outage Reported in $($workload.WorkloadDisplayName)" --bodyContents "Any outage has been reported for the Service : $($workload.WorkloadDisplayName) <a href='https://aum365.sharepoint.com/sites/M365CLI/Lists/O365%20Health%20Status'>Access the Health Status List</a>" --bodyContentType HTML
    }
}

 #Updating the status to IsInOutage to NO the list item if the service is back to normal
Foreach ($currentOutageService in $currentOutageServices){
    if($currentOutageService.Workload -notin $workLoads.Workload){
        $RemovedRecord = m365 spo listitem remove --webUrl $webURL --listTitle $listName --id  $currentOutageService.Id

        #Send notification using CLI Commands
        m365 outlook mail send --to "arjun@aum365.onmicrosoft.com" --subject "Outage RESOLVED for $($currentOutageService.WorkloadDisplayName)" --bodyContents "Outage which was reported for the Service : $($workload.WorkloadDisplayName) is RESOLVED." --bodyContentType HTML
    }
}
