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
    $workLoads = m365 tenant status list --output json --query "value[?Status != 'ServiceOperational']"

    Write-Host $workLoads
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

