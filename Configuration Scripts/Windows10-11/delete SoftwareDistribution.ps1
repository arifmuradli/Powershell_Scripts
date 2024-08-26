# Stop the Windows Update service, BITS service, and Cryptographic service
Stop-Service -Name wuauserv -Force
Stop-Service -Name bits -Force
Stop-Service -Name cryptsvc -Force

# Rename the SoftwareDistribution folder
$oldDir = "C:\Windows\SoftwareDistribution"
$newDir = "C:\Windows\SoftwareDistribution.old"

if (Test-Path $oldDir) {
    Rename-Item -Path $oldDir -NewName $newDir -Force
    Write-Output "Renamed SoftwareDistribution to SoftwareDistribution.old"
} else {
    Write-Output "SoftwareDistribution folder not found"
}

# Start the Windows Update service, BITS service, and Cryptographic service
Start-Service -Name wuauserv
Start-Service -Name bits
Start-Service -Name cryptsvc

# Delete the old SoftwareDistribution folder if it exists
if (Test-Path $newDir) {
    Remove-Item -Path $newDir -Recurse -Force
    Write-Output "Deleted SoftwareDistribution.old"
} else {
    Write-Output "SoftwareDistribution.old folder not found"
