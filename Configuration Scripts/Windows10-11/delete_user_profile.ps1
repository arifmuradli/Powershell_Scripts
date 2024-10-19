# Get user profile for a specific user
$UserProfile = Get-WmiObject Win32_UserProfile | Where-Object { $_.LocalPath -like "*C:\Users\arif.test*" }

# Check if the profile exists
if ($UserProfile) {
    # Remove the user profile
    $UserProfile.Delete()
    Write-Host "User profile deleted successfully."
} else {
    Write-Host "User profile not found."
}
