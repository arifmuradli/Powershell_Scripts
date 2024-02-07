# Created by arifmuradli, please give credit to my github account when you copy.
# Most intriguing point about this script is that it will check each directory and look for older files (for example 6 month old). If directory is empty it will delete that too.
# Values that I entered here can be manipulated according o your needs (180 {for 6 months}, D:\SourceFolder and logfile location)
$limit = (Get-Date).AddDays(-180)
$path = "D:\SourceFolder"
$logFilePath = "D:\CleanupLog.txt"

# Store paths of removed files
$removedFiles = Get-ChildItem -Path $path -Recurse -Force | Where-Object { 
    if (!$_.PSIsContainer -and $_.LastWriteTime -lt $limit) {
        $_.FullName
        return $true
    }
    return $false
}

# Remove files older than the $limit.
$removedFiles | Remove-Item -Force

# Output timestamped paths of removed files to log file
$removedFiles | ForEach-Object {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Removed: $_" | Out-File -Append -FilePath $logFilePath
}

# Delete any empty directories left behind after removing the old files.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { 
    $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null 
} | ForEach-Object {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $_.FullName
    Remove-Item -Path $_.FullName -Force -Recurse
    "[$timestamp] Removed: $_" | Out-File -Append -FilePath $logFilePath
}

Write-Host "Cleanup completed successfully."
