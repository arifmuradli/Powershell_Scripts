$shares = @()
$DFSshares = Get-DfsnFolder -path '\\domain.com\namespace\*' 
foreach($dfsshare in $DFSshares){
$shares += Get-DfsnFolderTarget -path $dfsshare.path | select path, targetpath}
$shares | export-csv c:\dfsshares.csv
