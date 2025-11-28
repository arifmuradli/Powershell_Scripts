# Monitor-SMBDialect-Servers.ps1
# Monitors SMB connections for dialects other than 3.1.1 in OU=Servers,DC=domain,DC=local

# Fixed OU
$OU = "OU=servers,DC=domain,DC=local"

Write-Host "Starting SMB dialect monitoring for OU: $OU"

# Get computers in the OU
try {
    $computers = Get-ADComputer -Filter * -SearchBase $OU -Properties Name | Select-Object -ExpandProperty Name
    if (-not $computers) {
        Write-Host "No computers found in OU: $OU"
        exit
    }
    Write-Host "Found $($computers.Count) computers in OU"
} catch {
    Write-Host "Error querying OU: $_"
    exit
}

# Check SMB sessions on each computer
foreach ($computer in $computers) {
    Write-Host "Checking SMB sessions on $computer"
    try {
        if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
            $sessions = Invoke-Command -ComputerName $computer -ScriptBlock {
                Get-SmbSession | Select-Object ClientComputerName, Dialect
            }
            if (-not $sessions) {
                Write-Host "No active SMB sessions on $computer"
                continue
            }
            foreach ($session in $sessions) {
                if ($session.Dialect -ne "3.1.1") {
                    Write-Host "Non-3.1.1 dialect detected on $computer from $($session.ClientComputerName): Dialect $($session.Dialect)"
                } else {
                    Write-Host "SMB 3.1.1 session confirmed on $computer from $($session.ClientComputerName)"
                }
            }
        } else {
            Write-Host "Computer $computer is offline"
        }
    } catch {
        Write-Host "Error checking $computer: $_"
    }
}

Write-Host "SMB dialect monitoring completed"
