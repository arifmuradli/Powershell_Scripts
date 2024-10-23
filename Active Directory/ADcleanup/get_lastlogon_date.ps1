#lastlogon - only on 1 DC (Windows File Time format). This is a 64-bit integer that represents the number of 100-nanosecond intervals since January 1, 1601 (UTC).
#lastlogondate - Replicated among all DCs. (Human Readable Format)
#LastLogonTimestamp - Same as lastlogondate but in (Windows File Time format).


$OneYearAgo = (Get-Date).AddYears(-1)
$OU = "OU=XXX,DC=XXX,DC=local"
$OneYearAgoFileTime = $OneYearAgo.ToFileTime()


Get-ADUser -Filter "lastLogonTimestamp -lt $OneYearAgoFileTime" -SearchBase $OU -Properties LastLogonTimestamp, lastlogon, lastlogondate, enabled, title | 
Select-Object Name, SamAccountName, enabled, title, distinguishedname, lastlogon, lastlogontimestamp, @{Name="LastLogonDate";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | ft
