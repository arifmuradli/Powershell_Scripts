# Find local user accounts with "Password never expires" set
$users = Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.LocalAccount -eq $true }

foreach ($user in $users) {
    $userObject = [ADSI]"WinNT://$($env:COMPUTERNAME)/$($user.Name),user"
    $userObject.UserFlags[0] -band 0x10000

    if ($userObject.UserFlags[0] -band 0x10000) {
        Write-Host "User $($user.Name) has 'Password never expires' option set"
        # Change "Password never expires" to $false
        $userObject.UserFlags[0] = $userObject.UserFlags[0] -bxor 0x10000
        $userObject.CommitChanges()
        Write-Host "Changed 'Password never expires' to $false for $($user.Name)"
    }
}
