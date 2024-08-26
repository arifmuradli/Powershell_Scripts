###Before running this script your first script should look like this
####New-DfsnFolder -Path '\\nameserver.domain.local\BranchA\Folder1'  -EnableTargetFailback $true  -TargetPath '\\fileserver-NODE01-P\BranchA\Folder1' -ReferralPriorityClass GlobalHigh -ReferralPriorityRank 0

# Define the path to the file
$filePath = "C:\Path\To\Your\File.txt"

# Check if the file exists
if (Test-Path $filePath) {
    # Read the content of the file
    $fileContent = Get-Content $filePath
    
    # Perform the replacements
    $fileContent = $fileContent -replace 'New-DfsnFolder', 'New-DfsnFolderTarget'
    $fileContent = $fileContent -replace ' -EnableTargetFailback \$true ', ' '
    $fileContent = $fileContent -replace 'NODE01', 'NODE02'
    $fileContent = $fileContent -replace 'GlobalHigh', 'GlobalLow'
    $fileContent = $fileContent -replace 'ReferralPriorityRank 0', 'ReferralPriorityRank 5'
    
    # Save the modified content back to the file
    Set-Content -Path $filePath -Value $fileContent
    
    Write-Host "File modifications completed successfully."
} else {
    Write-Host "File not found at path: $filePath"
}



###After implementing this script your output file will look like this
####New-DfsnFolderTarget -Path '\\nameserver.domain.local\BranchA\Folder1' -TargetPath '\\fileserver-NODE02-P\BranchA\Folder1'  -ReferralPriorityClass GlobalLow  -ReferralPriorityRank 5
