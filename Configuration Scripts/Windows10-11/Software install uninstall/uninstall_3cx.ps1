Stop-Process -name 3CX* -Force
$application = Get-WmiObject -Class Win32_Product -Filter "Name = '3CX Desktop APP'"
$application.Uninstall()
Remove-Item C:\Users\*\AppData\Roaming\3CXDesktopApp -Recurse
Remove-Item C:\Users\*\AppData\Local\Programs\3CXDesktopApp -Recurse
Remove-Item "C:\Users\*\Desktop\3CX Desktop App.lnk" -Recurse
