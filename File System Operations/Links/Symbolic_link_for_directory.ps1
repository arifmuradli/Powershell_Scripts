# Create a symbolic link for a directory
# Parameters: 
# $sourcePath - The path of the original directory
# $linkPath - The path where the symbolic link will be created

param(
    [string]$sourcePath,
    [string]$linkPath
)

New-Item -ItemType SymbolicLink -Path $linkPath -Target $sourcePath -Force

Write-Host "Symbolic link created from $linkPath to $sourcePath"
