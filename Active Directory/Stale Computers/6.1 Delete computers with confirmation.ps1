#### This script will skip Out-Gridview and just ask for the confirmation before deletion
# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU distinguished name (DN)
$ouDN = "ou=Disabled Computers,OU=Recycle_users-computers,DC=accessbank,DC=local"

# Calculate the date one year ago from today
$oneYearAgo = (Get-Date).AddYears(-1)

# Retrieve the list of computer objects from the specified OU with LastLogonTimestamp
$computers = Get-ADComputer -SearchBase $ouDN -Filter * -Properties LastLogonTimestamp | 
             Select-Object Name, LastLogonTimestamp

# Convert the LastLogonTimestamp to a readable date format, filter by date, and sort the results
$results = $computers | ForEach-Object {
    $logonDate = [DateTime]::FromFileTime($_.LastLogonTimestamp)
    if ($logonDate -lt $oneYearAgo) {
        [PSCustomObject]@{
            Name               = $_.Name
            LastLogonTimestamp = $logonDate
        }
    }
} | Sort-Object LastLogonTimestamp

# Display the results
$results

# Prompt user for confirmation before deleting computers
if ($results.Count -gt 0) {
    $confirmation = Read-Host "Do you want to delete these $($results.Count) computers? (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        foreach ($computer in $results) {
            Remove-ADComputer -Identity $computer.Name -Confirm:$false
            Write-Output "Deleted computer $($computer.Name)"
        }
    } else {
        Write-Output "Deletion operation canceled."
    }
} else {
    Write-Output "No inactive computers found to delete."
}
