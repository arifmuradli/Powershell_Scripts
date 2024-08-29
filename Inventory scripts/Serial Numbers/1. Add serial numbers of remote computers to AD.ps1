### This script should be run from the server that have access to all endpoints
### This script ignores "Default string", "System Serial Number", "To be filled by O.E.M."

# Define the OU distinguished name
$ouDN = "OU=Computers,DC=domain,DC=local"

# Define the path to the log file
$logFilePath = "C:\Logs\AD_Computer_Serial_Log.txt"

# Import the Active Directory module
Import-Module ActiveDirectory

# Get the current timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Initialize the log file with the timestamp
"[$timestamp] Script execution started." | Out-File -FilePath $logFilePath -Encoding utf8

# Get the list of computer objects in the specified OU
$computers = Get-ADComputer -Filter * -SearchBase $ouDN


# Define an array of invalid serial numbers
$invalidSerialNumbers = @("Default string", "System Serial Number", "To be filled by O.E.M.")

foreach ($computer in $computers) {
    # Get the computer's name
    $computerName = $computer.Name

    # Check if the computer is online
    if (Test-Connection -ComputerName $computerName -Count 2 -Quiet) {
        try {
            # Retrieve the serial number from the remote computer
            $serialNumber = (Get-CimInstance -ComputerName $computerName -ClassName Win32_BIOS).SerialNumber

            # Check if the serial number is valid
            if ($invalidSerialNumbers -contains $serialNumber) {
                $ignoreMessage = "Ignoring invalid serial number '$serialNumber' for computer $computerName."
                Write-Output $ignoreMessage
                # Log ignore message to the file
                $ignoreMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
            }
            else {
                # Update the AD computer object with the serial number
                Set-ADComputer -Identity $computerName -Add @{serialNumber=$serialNumber}

                # Output the result
                $output = "Serial number $serialNumber has been updated for computer $computerName in Active Directory."
                Write-Output $output
                # Log success message to the file
                $output | Out-File -FilePath $logFilePath -Append -Encoding utf8
            }
        }
        catch {
            # Handle errors (e.g., computer unreachable)
            $errorOutput = "Failed to update serial number for computer $computerName : $_"
            Write-Output $errorOutput
            # Log error message to the file
            $errorOutput | Out-File -FilePath $logFilePath -Append -Encoding utf8
        }
    }
    else {
        # Output message for offline computers
        $offlineOutput = "Skipping $computerName as it is offline."
        Write-Output $offlineOutput
        # Log offline message to the file
        $offlineOutput | Out-File -FilePath $logFilePath -Append -Encoding utf8
    }
}

# Log the completion of the script
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Script execution completed." | Out-File -FilePath $logFilePath -Append -Encoding utf8
