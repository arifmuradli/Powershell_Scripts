# Create a hard link
# Parameters: 
# $sourcePath - The path of the original file
# $linkPath - The path where the hard link will be created

param(
    [string]$sourcePath,
    [string]$linkPath
)

New-Item -ItemType HardLink -Path $linkPath -Target $sourcePath

Write-Host "Hard link created from $linkPath to $sourcePath"
