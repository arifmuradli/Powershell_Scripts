### this will give you alert with the list of users that have no manager assigned in AD

$OU = "OU=users,DC=domain,DC=local"  # The main OU where you're searching
$ExcludeOUs = @(
    "OU=Contractors,OU=users,DC=domain,DC=local",
    "OU=svc_accounts,OU=users,DC=domain,DC=local", 
    "OU=Test_ou,OU=MNO_ITOPS,OU=MNO_IT,OU=MO,OU=users,DC=domain,DC=local"
)  # OUs to exclude

$ExcludeUsers = @("corporate.secretary", "d.tsiklauri")  # List of users to exclude by SamAccountName

# Get users without a manager in the main OU
$UsersWithoutManager = Get-ADUser -LDAPFilter "(!manager=*)" -SearchBase $OU -Properties SamAccountName, title, DistinguishedName | 
    Where-Object {
        $userDN = $_.DistinguishedName
        $samAccountName = $_.SamAccountName
        # Exclude users whose DN starts with any of the excluded OUs and specific users by SamAccountName
        $ExcludeOUs -notcontains ($userDN -replace '^.*?,OU=', 'OU=')  -and ($ExcludeUsers -notcontains $samAccountName)
    } | 
    Select-Object Name, SamAccountName, title, DistinguishedName

# Build HTML Table
$HtmlTable = @"
These users have no manager defined
<br>
<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; font-family: Arial; font-size: 12px;">
    <tr>
        <th style="background-color: #f2f2f2;">Name</th>
        <th style="background-color: #f2f2f2;">SamAccountName</th>
        <th style="background-color: #f2f2f2;">DistinguishedName</th>
		<th style="background-color: #f2f2f2;">title</th>
    </tr>
"@

# Add rows to the HTML table
foreach ($user in $UsersWithoutManager) {
    $HtmlTable += "<tr>"
    $HtmlTable += "<td>" + $user.Name + "</td>"
    $HtmlTable += "<td>" + $user.SamAccountName + "</td>"
    $HtmlTable += "<td>" + $user.DistinguishedName + "</td>"
	$HtmlTable += "<td>" + $user.title + "</td>"
    $HtmlTable += "</tr>"
}

$HtmlTable += "</table>"

# Define email parameters
$EmailParams = @{
    To       = "arif.muradli@domain.local", "92f35977.domain.local@apac.teams.ms"
    From     = "arif.muradli@domain.local"
    Subject  = "AD Users Without Manager"
    Body     = $HtmlTable
    SmtpServer = "mailserver.domain.local"  # Replace with your SMTP server
    BodyAsHtml = $true
	Port = 587
}

# Send email
Send-MailMessage @EmailParams
