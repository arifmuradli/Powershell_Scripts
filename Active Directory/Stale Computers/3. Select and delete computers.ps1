### This script visually shows list of stale computers, so you can select and delete
### Ue this if you want to be extra careful about what you are doing
# Define the distinguished name (DN) of the specific OU you want to target
$ouDN = "OU=Disabled Computers,DC=domain,DC=local"

# Get the current date
$currentDate = Get-Date

# Calculate the date 6 months ago
$sixMonthsAgo = $currentDate.AddMonths(-6)

# Retrieve computer accounts from the specified OU with LastLogonDate 6 months ago or older
$staleComputers = Get-ADComputer -Filter * -SearchBase $ouDN -Properties Name, DistinguishedName, LastLogonDate, Enabled |
    Where-Object { $_.LastLogonDate -lt $sixMonthsAgo } |
    Sort-Object LastLogonDate

# Select the desired properties and export to CSV
$selectedComputers = $staleComputers |
    Select-Object Name, DistinguishedName, LastLogonDate, Enabled

# Display the selected computers in a grid view and allow the user to choose which computers to delete
$selectedToDelete = $selectedComputers | Out-GridView -Title "Select Computers to Delete" -PassThru

# Delete the selected computers
if ($selectedToDelete.Count -gt 0) {
    foreach ($computer in $selectedToDelete) {
        Remove-ADObject -Identity $computer.DistinguishedName -Confirm:$false
        Write-Host "Deleted computer: $($computer.Name)"
    }
} else {
    Write-Host "No computers selected for deletion."
}
