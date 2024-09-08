# Set the OU path where the groups are located
$sourceOU = "OU=Shares,OU=Groups,DC=domain,DC=local"

# Export the groups to a CSV file
Get-ADGroup -Filter * -SearchBase $sourceOU | Select-Object Name, SamAccountName, GroupScope, GroupCategory | Export-Csv -Path "C:\ExportedGroups.csv" -NoTypeInformation

# Import the CSV file
$groups = Import-Csv -Path "C:\ExportedGroups.csv"

# Set the target OU where the groups should be created
$targetOU = "OU=Shares,OU=All_groups,DC=testdomain,DC=local"

# Loop through each group and create it in the target domain
foreach ($group in $groups) {
    New-ADGroup -Name $group.Name -SamAccountName $group.SamAccountName -GroupScope $group.GroupScope -GroupCategory $group.GroupCategory -Path $targetOU
}
