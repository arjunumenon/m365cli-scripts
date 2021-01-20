Function getStatus(){
    #Get the Tenant Status List
    $Workloads = m365 tenant status list --output json | ConvertFrom-Json

    # $Workloads.value | ForEach-Object { Write-Host $_.StatusDisplayName }
    $Filtered =  $Workloads.value |? Status -ne "ServiceOperational"

    foreach ($workload in $Filtered) { 
        Write-Output "Workfload: $($workload.WorkloadDisplayName)"
    }
}

Function getStatusJMES(){
    $workLoads = m365 tenant status list --query "value[?Status != 'ServiceOperational']"  --output json  | ConvertFrom-Json
    $workLoads | ForEach-Object { $AddedItem = m365 spo listitem add --contentType Item --listTitle "O365 Health Status" --webUrl https://aum365.sharepoint.com/sites/M365CLI --Title $_.WorkloadDisplayName}
}

#Check the Login Status
$LoginStatus = m365 status


if($LoginStatus -Match "connectedAs:"){
    Write-Host "Connected"

    #getStatus
    getStatusJMES
    
}
else {
    Write-Host "Not Connected"
}

