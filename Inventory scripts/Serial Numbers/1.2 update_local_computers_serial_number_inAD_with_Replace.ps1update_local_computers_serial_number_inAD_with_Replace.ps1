### This script updates serial number of local computer to AD
### This script should run from local endpoint
### This script uses "Replace" parameter instead of ADD parameter
# Get the serial number of the computer
$serialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

# Get the current computer's name
$computerName = $env:COMPUTERNAME

# Import the Active Directory module
Import-Module ActiveDirectory

# Update the AD computer object with the serial number
Set-ADComputer -Identity $computerName -Replace @{serialNumber=$serialNumber}

# Output the result
Write-Output "Serial number $serialNumber has been updated for computer $computerName in Active Directory."
