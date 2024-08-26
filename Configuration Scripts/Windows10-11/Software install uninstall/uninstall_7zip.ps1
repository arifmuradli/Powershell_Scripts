### Usually when new version 7zip is installed, old one's registry key still remains. Uninstall old one and install new one just to be sure
Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq "7-Zip 22.01 (x64 edition)"} | ForEach-Object { $_.Uninstall() }
