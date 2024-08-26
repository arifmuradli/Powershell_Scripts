### When you have nested OUs, and required to get list of all users, and exclude specific OU or groups that include service accounts
### This script will exclude 
# Import the Active Directory module
Import-Module ActiveDirectory

# Define the base OU and specific folders to exclude
$baseOU = "OU=ALL USERS,DC=domain,DC=local"
$excludedOUs = "OU=Vendors,OU=ALL USERS,DC=domain,DC=local", "OU=Long_leave,OU=ALL USERS,DC=domain,DC=local", "OU=service_accounts,OU=ALL USERS,DC=domain,DC=local", "OU=Pending,OU=ALL USERS,DC=domain,DC=local"
$excludedFolders = "CN=ExcludedGroup1,OU=Users,DC=example,DC=com", "CN=ExcludedGroup2,OU=Users,DC=example,DC=com"

# Get active user accounts excluding specific OUs and folders
$activeUsers = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $baseOU -SearchScope Subtree -Properties department, displayname, Office |
    Where-Object { $_.DistinguishedName -notin $excludedOUs -and $_.DistinguishedName -notin $excludedFolders } 

# Select the properties you want to export
$selectedUsers = $activeUsers  | Select-Object Displayname, department, office, SamAccountName, Distinguishedname | Sort-Object department

# Export the results to a CSV file
$selectedUsers  | Export-Csv -Path "C:\data\usersactive.csv" -NoTypeInformation
