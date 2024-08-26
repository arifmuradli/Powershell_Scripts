## This script uses LastLogonTimestamp instead of LastLogon or LastLogonDate
###LastLogonTimestamp: This is typically the most accurate for identifying inactive computers. It's replicated across domain controllers, so it provides a consistent value across the domain, but it's not updated in real-time—it can be up to 14 days behind.
####LastLogon: This is the most precise as it's updated every time a user logs in, but it's only stored on the domain controller that handled the login, so it requires querying all domain controllers to get an accurate picture.
#####LastLogonDate: This is not a built-in attribute in AD but is often used in scripts as a human-readable format of LastLogonTimestamp. It's convenient for reporting but doesn't offer additional accuracy beyond LastLogonTimestamp.
# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU distinguished name (DN)
$ouDN = "OU=Computers,DC=domain,DC=local"

# Calculate the date one year ago from today
$oneYearAgo = (Get-Date).AddYears(-1)

# Retrieve the list of computer objects from the specified OU with LastLogonTimestamp
$computers = Get-ADComputer -SearchBase $ouDN -Filter * -Properties LastLogonTimestamp | 
             Select-Object Name, LastLogonTimestamp

# Filter computers where LastLogonTimestamp is exactly one year ago
$results = $computers | Where-Object {
    [DateTime]::FromFileTime($_.LastLogonTimestamp) -eq $oneYearAgo
} | Sort-Object LastLogonTimestamp

# Export the results to a CSV file
$results | Export-Csv -Path "C:\data\stale.csv" -NoTypeInformation

# Output the results to the console (optional)
$results
