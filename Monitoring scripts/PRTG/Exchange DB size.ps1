### source: https://kb.paessler.com/en/topic/63229-how-can-i-monitor-additional-values-of-exchange-databases
#-----Please adjust to your Exchange server:
$CURI="http://exchangeserver.domain.tld/PowerShell/"
#--------------

Function SizeInBytes ($itemSizeString)
{
    $posOpenParen = $itemSizeString.IndexOf("(") + 1
    $numCharsInSize = $itemSizeString.IndexOf(" bytes") - $posOpenParen 
    $SizeInBytes = $itemSizeString.SubString($posOpenParen,$numCharsInSize).Replace(",","")
	return $SizeInBytes 
}

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $CURI -Authentication Kerberos
Import-PSSession $Session -DisableNameChecking

$dbs = Get-MailboxDatabase -Status

$result= "<?xml version=`"1.0`" encoding=`"Windows-1252`" ?>`r`n"
$result+="<prtg>`r`n"

foreach($db in $dbs)
{
	$dbname=$db.name
	$dbsize=SizeInBytes($db.DatabaseSize)
	$whitespace=SizeInBytes($db.availablenewmailboxspace)

	$edbFilePath = ("\\"+$db.ServerName+"\"+ $db.EdbFilePath.tostring().replace(":","$"))
	$i = $edbFilePath.LastIndexOf('\')
	$edbFilePath = $edbFilePath.Remove($i+1)
	$guid = $db.Guid.ToString()
	$dir = (get-childitem $edbFilePath | where { $_.Name.Contains($guid) })
	$idxdir=$edbFilePath+$dir
	$idxsize=(Get-ChildItem $idxdir | Measure-Object -Property Length -Sum).Sum

	$result+="   <result>`r`n"
	$result+="       <channel>DB-Size "+$dbname+"</channel>`r`n"
	$result+="       <unit>BytesFile</unit>`r`n"
	$result+="       <value>"+$dbsize+"</value>`r`n"
	$result+="   </result>`r`n"
	$result+="   <result>`r`n"
	$result+="       <channel>Whitespace "+$dbname+"</channel>`r`n"
	$result+="       <unit>BytesFile</unit>`r`n"
	$result+="       <value>"+$whitespace+"</value>`r`n"
	$result+="   </result>`r`n"
	$result+="   <result>`r`n"
	$result+="       <channel>Size Index "+$dbname+"</channel>`r`n"
	$result+="       <unit>BytesFile</unit>`r`n"
	$result+="       <value>"+$idxsize+"</value>`r`n"
	$result+="   </result>`r`n"
}		
$result+="   <text>OK</text>`r`n"
$result+="</prtg>`r`n"
$result
remove-pssession -session $Session
Exit 0
