# Function to display BitLocker information
function Get-BitLockerInfo {
    param (
        [string]$volume
    )

    $bitLockerInfo = Get-BitLockerVolume -MountPoint $volume

    # Check if BitLocker is enabled on the volume
    if ($bitLockerInfo.ProtectionStatus -eq 'On') {
        Write-Host "BitLocker is enabled on volume $($bitLockerInfo.MountPoint)"

        # Display encryption status
        Write-Host "Encryption Status: $($bitLockerInfo.EncryptionPercentage)%"

        # Display protectors
        Write-Host "Protectors:"
        foreach ($protector in $bitLockerInfo.KeyProtector) {
            Write-Host "  $($protector.KeyProtectorType): $($protector.KeyProtectorID)"
        }

        # Display recovery ID
        Write-Host "Recovery ID: $($bitLockerInfo.RecoveryKeyPath.Split('\')[-1])"

        # Display recovery key
        $recoveryKey = Get-Content $bitLockerInfo.RecoveryKeyPath
        Write-Host "Recovery Key:"
        Write-Host $recoveryKey
    } else {
        Write-Host "BitLocker is not enabled on volume $($bitLockerInfo.MountPoint)"
    }
}

# Specify the volume for which you want to get BitLocker information
$volume = "C:"

# Call the function with the specified volume
Get-BitLockerInfo -volume $volume
