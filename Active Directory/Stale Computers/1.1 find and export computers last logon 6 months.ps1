# Define the distinguished name (DN) of the specific OU you want to target
$ouDN = "OU=servers,DC=domain,DC=local"

# Get the current date
$currentDate = Get-Date

# Calculate the date 6 months ago
$sixMonthsAgo = $currentDate.AddMonths(-6)

# Retrieve computer accounts from the specified OU with last logon within the last 6 months
Get-ADComputer -Filter * -SearchBase $ouDN -Properties * |
    Where-Object { [DateTime]::FromFileTime($_.LastLogon) -lt $sixMonthsAgo } |
    Sort-Object LastLogon |
    Select-Object Name, DistinguishedName, LastLogonDate, Enabled, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}} |
    Export-Csv C:\adcomputers-last-logon.csv -NoTypeInformation
