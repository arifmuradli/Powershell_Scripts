### This script updates serial number of local computer to AD
### This script should run from local endpoint
### This script uses "Add" parameter instead of "Replace" parameter
# Get the serial number of the computer
$serialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

# Get the current computer's name
$computerName = $env:COMPUTERNAME

# Import the Active Directory module
Import-Module ActiveDirectory

# Update the AD computer object with the serial number
Set-ADComputer -Identity $computerName -Add @{serialNumber=$serialNumber}

# Output the result
Write-Output "Serial number $serialNumber has been updated for computer $computerName in Active Directory."
