### This script detects Software distribution Folder which is larger than 3GB
# Define the threshold size in bytes (3GB)
$thresholdSize = 3GB

# Get the current date and time
$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Get the size of the Software Distribution folder
$softwareDistributionPath = "$env:SystemRoot\SoftwareDistribution"
$folderSize = (Get-ChildItem -Path $softwareDistributionPath -Recurse | Measure-Object -Property Length -Sum).Sum

# Convert the size to gigabytes
$folderSizeGB = $folderSize / 1GB

# Check if the folder size is above the threshold
if ($folderSizeGB -gt 3) {
    # Stop Windows Update service and BITS service
    Stop-Service -Name wuauserv, bits -Force

    # Rename Software Distribution folder to SoftwareDistribution_old
    Rename-Item -Path $softwareDistributionPath -NewName "SoftwareDistribution_old" -Force

    # Start Windows Update service and BITS service
    Start-Service -Name wuauserv, bits

    # Wait for a moment to ensure services have started
    Start-Sleep -Seconds 5

    # Delete SoftwareDistribution_old folder
    $oldFolderPath = "$env:SystemRoot\SoftwareDistribution_old"
    Remove-Item -Path "$oldFolderPath\*" -Recurse -Force

    # Log the action
    $logMessage = "$currentDate : Task started, detected $($folderSizeGB.ToString("F2")) GB size, and deleted it"
    Add-Content -Path "C:\Windows\Logs\softwaredistributionremovelog.txt" -Value $logMessage

    Write-Host "Software Distribution folder size was above 3GB. Actions completed."
} else {
    # Log the action
    $logMessage = "$currentDate : Task started, detected $($folderSizeGB.ToString("F2")) GB size, and did nothing"
    Add-Content -Path "C:\Windows\Logs\log.txt" -Value $logMessage

    Write-Host "Software Distribution folder size is below 3GB. No action taken."
}
