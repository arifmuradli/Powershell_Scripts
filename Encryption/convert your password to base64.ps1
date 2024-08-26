$password = "YourPassword"
$passwordBytes = [System.Text.Encoding]::UTF8.GetBytes($password)
$base64Password = [System.Convert]::ToBase64String($passwordBytes)
Write-Output $base64Password
