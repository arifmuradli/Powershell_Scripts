Param([string]$RemotePC)
# First line in for running this script from PRTG.
# If you run this script from PRTG, enter remote computer name as parameter.
# If you run this from your computer, just remove first line and add $RemotePC =  value [to the first line].
# This script is especially useful if you want to remotely monitor dashboards, that must be running with specific links opened.
# $RemotePC is the dashboard that is located in office or branch.
# You can nslookup to the root of of the url, and get destination IP.
$destinationIP = "192.168.XXX.XXX"
$destinationPort = 443

# Create a credential object
# Account with administrator privilages is necessary
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
    $connection = Get-NetTCPConnection -RemoteAddress $destinationIP -RemotePort $destinationPort

    # Check if a connection is established
    if ($connection -and $connection.State -eq 'Established') {
        write-output "1:OK"
		exit 0
    } else {
       write-output "0: Not Connected"
	   exit 1
    }
}

# Invoke the command on the remote machine
$result = Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $destinationIP, $destinationPort

# Display the result
$result

# Removing PS-Session is optional
#Remove-PSSession $session
# Please take into consideration that this script does not check whether the connection to specific address with specific port is possible or not; whether the port is open or not. It just don't care about it :)
# This script only checks if the page is open in browser or not. If you close the browser, or browser crushes, it will return value as notconncted, even if remote port is open.
# Created by arifmuradli, please give credit to my github account when you copy. 
