#MOstRecent Last LOgon among All DCs

$DCs = Get-ADDomainController -Filter *  # Get all Domain Controllers
$User = "username"  # Specify the username here

$LastLogonTimes = @()

foreach ($DC in $DCs) {
    $Logon = Get-ADUser $User -Server $DC.HostName -Properties LastLogon | Select-Object Name, @{Name="LastLogon";Expression={[DateTime]::FromFileTime($_.LastLogon)}}
    $LastLogonTimes += $Logon
}

# Find the most recent logon time
$MostRecentLogon = $LastLogonTimes | Sort-Object LastLogon -Descending | Select-Object -First 1
$MostRecentLogon
