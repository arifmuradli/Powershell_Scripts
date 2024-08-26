### This script has prerquisites, $templateFilePath must include MainSign.html which is published in this folder

# Gets the path to the user appdata folder
$AppData = (Get-Item env:appdata).value
# This is the default signature folder for Outlook
$localSignatureFolder = $AppData+'\Microsoft\Signatures'
# This is a shared folder on your network where the signature template should be
$templateFilePath = "\\domain.local\SYSVOL\domain.local\scripts\signature template"

# Clean the signature foder
Remove-Item -Path $localSignatureFolder\* -Recurse -Exclude "signature_image02.jpg"

# Get the current logged in username and AD attributes
$UserName = $env:username 
$Filter = "(&(objectCategory=User)(samAccountName=$UserName))" 
$Searcher = New-Object System.DirectoryServices.DirectorySearcher 
$Searcher.Filter = $Filter 
$ADUserPath = $Searcher.FindOne() 
$ADUser = $ADUserPath.GetDirectoryEntry() 
$DisplayName = $ADUser.DisplayName 
$EmailAddress = $ADUser.mail 
$Title = $ADUser.title
$ip = $ADUser.telephoneNumber
$phone = $ADUser.homePhone
$address = $ADUser.streetAddress
$mobile = $ADUser.mobile
$department = $ADUser.department


$displaynamePlaceHolder = "DISPLAY_NAME"
$emailaddressPlaceHolder = "EMAIL_ADDRESS"
$titlePlaceHolder = "JOB_TITLE"
$departmentPlaceHolder = "Department1"
$phonePlaceHolder = "HOME_PHONE"
$ipPlaceHolder = "IP_PHONE"
$addressPlaceHolder = "STREET_ADDRESS"
$mobilePlaceHolder = "MOBILE_PHONE"


$rawTemplate = get-content $templateFilePath"\MainSign.html"

$signature = $rawTemplate -replace $displaynamePlaceHolder,$DisplayName
$rawTemplate = $signature

$signature = $rawTemplate -replace $emailaddressPlaceHolder,$EmailAddress
$rawTemplate = $signature

$signature = $rawTemplate -replace $phonePlaceHolder,$phone
$rawTemplate = $signature

$signature = $rawTemplate -replace $titlePlaceHolder,$title
$rawTemplate = $signature

$signature = $rawTemplate -replace $departmentPlaceHolder,$department
$rawTemplate = $signature

$signature = $rawTemplate -replace $ipPlaceHolder,$ip
$rawTemplate = $signature

$signature = $rawTemplate -replace $addressPlaceHolder,$address
$rawTemplate = $signature

$signature = $rawTemplate -replace $mobilePlaceHolder,$mobile
$rawTemplate = $signature

# Save it as <username>.htm
$fileName = $localSignatureFolder + "\" + $userName + ".htm"

# Gets the last update time of the template.
if(test-path $templateFilePath){
    $templateLastModifiedDate = [datetime](Get-ItemProperty -Path $templateFilePath -Name LastWriteTime).lastwritetime
}

# Checks if there is a signature and its last update time
if(test-path $filename){
    $signatureLastModifiedDate = [datetime](Get-ItemProperty -Path $filename -Name LastWriteTime).lastwritetime
    if((get-date $templateLastModifiedDate) -gt (get-date $signatureLastModifiedDate)){
        $signature > $fileName
    }
}else{
    $signature > $fileName
}

If (Test-Path HKCU:'\Software\Microsoft\Office\15.0') { 
    Write-Output "YEAP" 
    If (Get-ItemProperty -Name 'NewSignature' -Path HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings') { }  
    Else {  
        New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'NewSignature' -Value $UserName -PropertyType 'ExpandString' -Force  
    }
    If (Get-ItemProperty -Name 'ReplySignature' -Path HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings') { }  
    Else {  
        New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'ReplySignature' -Value $UserName -PropertyType 'ExpandString' -Force 
    }  
}

If (Test-Path HKCU:'\Software\Microsoft\Office\16.0') { 
    Write-Output "YEAP" 
    If (Get-ItemProperty -Name 'NewSignature' -Path HKCU:'\Software\Microsoft\Office\16.0\Common\MailSettings') { }  
    Else {  
        New-ItemProperty HKCU:'\Software\Microsoft\Office\16.0\Common\MailSettings' -Name 'NewSignature' -Value $UserName -PropertyType 'ExpandString' -Force  
    }
    If (Get-ItemProperty -Name 'ReplySignature' -Path HKCU:'\Software\Microsoft\Office\16.0\Common\MailSettings') { }  
    Else {  
        New-ItemProperty HKCU:'\Software\Microsoft\Office\16.0\Common\MailSettings' -Name 'ReplySignature' -Value $UserName -PropertyType 'ExpandString' -Force 
    }  
}

Get-ItemProperty -Name 'First-Run' -Path HKCU:'\Software\Microsoft\Office\15.0\Outlook\Setup' | Remove-ItemProperty -Name 'First-Run'

Get-ItemProperty -Name 'First-Run' -Path HKCU:'\Software\Microsoft\Office\16.0\Outlook\Setup' | Remove-ItemProperty -Name 'First-Run'



