# Define the target OU
$targetOU = "OU=XXX,DC=domain,DC=local"

# Define the script block to execute on the remote computer
$scriptBlock = {
    $dotNetVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Version
    $dotNetVersion.Version
}

# Get computer names from the specified OU
$computersInOU = Get-ADComputer -Filter * -SearchBase $targetOU | Select-Object -ExpandProperty Name

# Loop through each computer in the OU and execute the script block
foreach ($computer in $computersInOU) {
    $dotNetVersion = Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock
    Write-Host "The .NET version on $computer is: $dotNetVersion"
}
