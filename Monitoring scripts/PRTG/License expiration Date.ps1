Param([string]$ExpirationDate)

$DateDifference = New-TimeSpan -Start (Get-Date) -End $ExpirationDate
$Days = $DateDifference.Days
$DaysPassed = ($Days * -1)
if($Days -gt 0){
                Write-Host "$($Days):License expires in $($Days) day(s)."
                exit 0 }
if($Days -eq 0){
                Write-Host "$($Days):The license expires today!";
                exit 1
}
if($Days -lt 0){
                Write-Host "0:License expired for $($DaysPassed) days!"
                exit 1
}

###Source: Paessler Support https://kb.paessler.com/en/topic/60478-how-can-i-monitor-licenses-in-my-network#reply-193369
## For PRTG, just add Date in Parameters of Sensor Settings
# Applicable Date Formats: YYYY-MM-DD; MM-DD-YYYY (can be varied with system time parameters)
