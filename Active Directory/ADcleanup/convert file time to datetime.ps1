# Convert the file time to a DateTime object
$FileTime = 132339360867624853
$LastLogonDate = [DateTime]::FromFileTime($FileTime)
$LastLogonDate
