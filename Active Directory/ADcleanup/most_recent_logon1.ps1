$User = "username"  # Specify the username here
$DCs = Get-ADDomainController -Filter *  # Get all Domain Controllers

$LastLogonTimes = @()

foreach ($DC in $DCs) {
    $Logon = Get-ADUser $User -Server $DC.HostName -Properties LastLogon | 
    Select-Object Name, @{Name="DC";Expression={$DC.HostName}}, @{Name="LastLogon";Expression={[DateTime]::FromFileTime($_.LastLogon)}}
    $LastLogonTimes += $Logon
}

# Output all the logon times from each DC
$LastLogonTimes

# Find the most recent logon time
$MostRecentLogon = $LastLogonTimes | Sort-Object LastLogon -Descending | Select-Object -First 1
$MostRecentLogon
