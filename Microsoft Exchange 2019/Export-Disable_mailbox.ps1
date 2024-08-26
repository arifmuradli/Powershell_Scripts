### Considering you have OU for Disabled_Users, you may want to export that mailboxes as pst and Disable those mailboxes to create whitespace in your DB
### Script will send mail alerts if fails and will write logs


Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Define variables
$OU = "OU=Disabled_Users,DC=domain,DC=local"
$ExportPath = "\\VEEAM\VEEAMMailboxes\"
$LogDirectory = "\\VEEAM\VEEAMMailboxes\Logs\"
$LogFile = "$LogDirectory$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
$RetryInterval = 1 # Minutes
$MaxRetries = 15 # Number of retries before considering the export as failed

# Ensure log directory exists
if (-not (Test-Path -Path $LogDirectory)) {
    try {
        New-Item -Path $LogDirectory -ItemType Directory | Out-Null
        Write-Host "Log directory created: $LogDirectory"
    } catch {
        Write-Host "Failed to create log directory: $_"
        exit 1
    }
}

# Initialize log
function Log-Message {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    try {
        Add-Content -Path $LogFile -Value "$Timestamp - $Message"
    } catch {
        Write-Host "Failed to write log: $_"
    }
}

# Export and disable mailbox
function Export-And-DisableMailbox {
    param (
        [Parameter(Mandatory=$true)]
        [string]$MailboxIdentity
    )

    # Retrieve mailbox details including alias
    $mailbox = Get-Mailbox -Identity $MailboxIdentity
    $Alias = $mailbox.Alias

    Log-Message "Starting export for mailbox: $MailboxIdentity (Alias: $Alias)"
    
    try {
        # Start the export request using the alias for naming the PST file
        New-MailboxExportRequest -Mailbox $MailboxIdentity -FilePath "$ExportPath\$Alias.pst"
        Log-Message "Export request initiated for mailbox: $MailboxIdentity (Alias: $Alias)"

        # Poll the status of the export request
        $retryCount = 0
        $status = "InProgress"
        
        while ($status -eq "InProgress" -or $status -eq "Queued") {
            Start-Sleep -Seconds ($RetryInterval * 60) # Convert minutes to seconds
            $exportRequest = Get-MailboxExportRequest -Mailbox $MailboxIdentity
            $status = $exportRequest.Status
            
            if ($status -eq "Completed") {
                Log-Message "Export completed for mailbox: $MailboxIdentity (Alias: $Alias)"
                Disable-Mailbox -Identity $MailboxIdentity -Confirm:$false
                Log-Message "Mailbox disabled: $MailboxIdentity (Alias: $Alias)"
                break
            } elseif ($status -eq "Failed") {
                Log-Message "Export failed for mailbox: $MailboxIdentity (Alias: $Alias)"
                # Send email notification (example configuration)
                $smtpServer = "mail.domain.az"
                $smtpFrom = "sender@domain.az"
                $smtpTo = "recipient@domain.az"
                $subject = "Mailbox Export Failed"
                $body = "The export for mailbox $MailboxIdentity has failed. Please check the logs for details."
                Send-MailMessage -SmtpServer $smtpServer -port 587 -From $smtpFrom -To $smtpTo -Subject $subject -Body $body
                break
            }

            # Handle retries
            $retryCount++
            if ($retryCount -ge $MaxRetries) {
                Log-Message "Maximum retries reached for mailbox: $MailboxIdentity (Alias: $Alias)"
                break
            }
        }
    } catch {
        Log-Message "Exception occurred for mailbox: $MailboxIdentity (Alias: $Alias). Error: $_"
    }
}

# Main script logic
$mailboxes = Get-Mailbox -OrganizationalUnit $OU
foreach ($mailbox in $mailboxes) {
    Export-And-DisableMailbox -MailboxIdentity $mailbox.Identity
}
