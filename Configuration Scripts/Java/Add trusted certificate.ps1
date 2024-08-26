
$keytoolPath = "C:\Program Files\Java\jre-1.8\bin\keytool.exe"
$cacertsPath = "C:\Program Files\Java\jre-1.8\lib\security\cacerts"
$certFilePath = "C:\Major\cert.crt"  # Replace with the path to your CA root certificate
$alias = "Root_CA_SUBCA"  # Replace with a suitable alias for the certificate

# Define the password for the cacerts keystore
$storePass = "changeit"  # Default password for cacerts. Change if you have modified it.

# Import the certificate
$keytoolCmd = $keytoolPath -importcert -trustcacerts -keystore $cacertsPath -storepass $storePass -noprompt -alias $alias -file $certFilePath
Invoke-Expression -Command $keytoolCmd

# Verify the import (optional)
$keytoolListCmd = "$keytoolPath -list -keystore $cacertsPath -storepass $storePass"
Invoke-Expression -Command $keytoolListCmd | Select-String -Pattern $alias
