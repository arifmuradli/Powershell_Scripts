#### This is not a very "secure" thing to do proceed only if you have to.
#### this script removes "SHA1 usage SignedJAR & denyAfter 2019-01-01" string from security file.
# Define the log file path
$logFilePath = "C:\Windows\Logs\java_security_edit.log"

# Function to log messages
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logMessage
}

# Define the primary and alternative paths
$primaryPath = "C:\Program Files\Java\jre*\lib\security\java.security"
$alternativePath = "C:\Program Files (86)\Java\jre*\lib\security\java.security"

# Check if the primary path exists, otherwise search for alternative paths
if (Test-Path $primaryPath) {
    $javaSecurityFilePath = $primaryPath
    Write-Log "Primary path found: $javaSecurityFilePath"
} else {
    $javaSecurityFilePath = Get-ChildItem -Path "C:\Program Files\Java\" -Recurse -Filter "java.security" | Select-Object -First 1 -ExpandProperty FullName
    if ($javaSecurityFilePath) {
        Write-Log "Alternative path found: $javaSecurityFilePath"
    } else {
        Write-Log "No java.security file found."
        exit
    }
}

# Backup the original file
$backupFilePath = "$javaSecurityFilePath.bak"
Copy-Item -Path $javaSecurityFilePath -Destination $backupFilePath -Force
Write-Log "Backup created at: $backupFilePath"

# Read and modify the file content
$fileContent = Get-Content -Path $javaSecurityFilePath
$newContent = $fileContent | Where-Object { $_ -notmatch "SHA1 usage SignedJAR & denyAfter 2019-01-01" }

# Write the new content back to the file
Set-Content -Path $javaSecurityFilePath -Value $newContent
Write-Log "Line removed from $javaSecurityFilePath"

Write-Log "Script completed successfully."
