Get-ADUser -identity username -properties PasswordLastSet, PasswordExpired, PasswordNeverExpires | ft Name, PasswordLastSet, PasswordExpired, PasswordNeverExpires
