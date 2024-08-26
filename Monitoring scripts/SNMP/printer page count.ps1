# Import the Net-SNMP module
Import-Module Net-SNMP

# Define SNMP parameters
$hostname = '192.168.XXX.XXX'   # Replace with your printer's IP or hostname
$communityString = 'public'         # Replace with your SNMP community string
$pageCountOID = '1.3.6.1.2.1.43.10.2.1.4.1.1'  # OID for page count (may vary)

# Perform the SNMP query to get the page count
$pageCount = Get-SNMP -HostName $hostname -Community $communityString -OID $pageCountOID

# Check for errors
if ($pageCount.Error -ne $null) {
    Write-Host "SNMP Error: $($pageCount.Error)"
}
else {
    Write-Host "Page Count: $($pageCount.Value)"
}
