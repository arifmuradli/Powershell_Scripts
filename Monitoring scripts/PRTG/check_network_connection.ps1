# This script is handy especially if there is site to site tunnel and you want to monitor whether remote side is up and accepts connection. 
# This script does not provide information about established connection but rather, it check if connection is possible or not, remote port is open or not.
# DestinationIP - is not necessarily has to be IP address, it may be a hostname as well and $RemotePC also can be IP address.

Param(
	[string]$destinationIP,
	[string]$destinationPort,
	[string]$RemotePC
	)

# Create a credential object
$username = "serviceaccount"
$password = ConvertTo-SecureString "p@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password

# Create a PSSession with the specified credentials
$session = New-PSSession -ComputerName "$RemotePC" -Credential $credential

# Define the script block to be executed on the remote machine
$scriptBlock = {
    param($destinationIP, $destinationPort)
    
    # Import the NetTCPIP module
    Import-Module NetTCPIP

    # Run Get-NetTCPConnection
    $connection = test-netconnection -RemoteAddress $destinationIP -remoteport $destinationPort

    # Check if a connection is established
    if ($connection -and $connection.TcpTestSucceeded -eq 'True') {
        write-output "1:$connection.TcpTestSucceeded"
		exit 0
    } else {
       write-output "0:$connection"
	   exit 1
    }
}

# Invoke the command on the remote machine
$result = Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $destinationIP, $destinationPort

# Display the result
$result

# Close the PSSession
#Remove-PSSession $session

# When entering to PRTG, input parameters as indicated below:
# -destinationIP 192.168.XX.XX -destinationPort XXX -RemotePC 192.168.XX.XX
