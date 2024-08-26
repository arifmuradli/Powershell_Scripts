### If you have multiple DC, you better use lastlogondate instead of last logon

# Define the distinguished name (DN) of the specific OU you want to target
$ouDN = "OU=servers,DC=domain,DC=local"

# Get the current date
$currentDate = Get-Date

# Calculate the date 6 months ago
$sixMonthsAgo = $currentDate.AddMonths(-6)

# Retrieve computer accounts from the specified OU with LastLogonDate 6 months ago or older
$staleComputers = Get-ADComputer -Filter * -SearchBase $ouDN -Properties Name, DistinguishedName, LastLogonDate, Enabled |
    Where-Object { $_.LastLogonDate -lt $sixMonthsAgo } |
    Sort-Object LastLogonDate

# Select the desired properties and export to CSV
$staleComputers |
    Select-Object Name, DistinguishedName, LastLogonDate, Enabled |
    Export-Csv C:\users\a.muradli\desktop\export\aadisabledserverss.csv -NoTypeInformation
