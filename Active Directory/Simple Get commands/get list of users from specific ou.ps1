# Connect to Active Directory
Import-Module ActiveDirectory

# Specify the OU path
$ouPath = "OU=XXX,OU=ZZZ,DC=domain,DC=local"

# Retrieve users from the specified OU and select username, description, and P.O. box
$users = Get-ADUser -Filter * -SearchBase "$ouPath" -Properties Description,POBox | Select-Object SamAccountName, Description, POBox

# Output the results
$users | Export-Csv -path C:\data\list_of_users.csv
