Function getStatus(){
    #Get the Tenant Status List
    $Workloads = m365 tenant status list --output json | ConvertFrom-Json

    $Workloads.value | ForEach-Object { Write-Host $_.StatusDisplayName }
    $Workloads.value |? Status -ne "ServiceOperational" | ForEach-Object { Write-Host $_.WorkloadDisplayName }

    # $Workloads = m365 tenant status list -o json | ConvertFrom-Json
    # foreach ($workload in $Workloads.value) { 
    #     Write-Output "Workfload: $($workload.Workload)"
    # }
}

#Check the Login Status
$LoginStatus = m365 status

if($LoginStatus -Match "connectedAs:"){
    Write-Host "Connected"

    getStatus
    
}
else {
    Write-Host "Not Connected"
}

