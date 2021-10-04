cls

#Check the Login Status
$LoginStatus = m365 status
if($LoginStatus -Match "Logged out"){
    #Executing login command for CLI
    m365 login   
}

#Reading from CSV
$GroupedResult = Import-Csv -Path .\Current-Permission-Migration.csv | Group-Object PermissionLevel | ForEach-Object {
[PsCustomObject]@{
    PermissionLevel = $_.Name
    UsernameValues = $_.Group.Username -join ', '
     }
}
# $GroupedResult | Format-Table

Foreach ($PermissionLevel in $GroupedResult) {
    #Write-Host $PermissionLevel.PermissionLevel
}
