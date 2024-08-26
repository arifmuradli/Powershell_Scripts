# Define the source and destination OUs
$sourceOU = "OU=servers,DC=domain,DC=local"
$destinationOU = "OU=DisabledServers,DC=domain,DC=local"

# Get disabled computer accounts from the source OU
$disabledComputers = Get-ADComputer -Filter {Enabled -eq $false} -SearchBase $sourceOU -Properties Name, DistinguishedName, Enabled

# Display the disabled computers in a grid view and allow user selection
$selectedComputers = $disabledComputers | Out-GridView -Title "Select disabled computers to move" -OutputMode Multiple

# Move selected disabled computers to the destination OU
foreach ($computer in $selectedComputers) {
    Move-ADObject -Identity $computer.DistinguishedName -TargetPath $destinationOU
    Write-Host "Moved $($computer.Name) to $destinationOU"
}

Write-Host "Move completed."
