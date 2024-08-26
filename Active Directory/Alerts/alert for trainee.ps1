### Alert needed for certain type of users that should only be active for certain amount of time
# Define the date filter for 3 months ago
$DateThreshold = (Get-Date).AddMonths(-3)

# Retrieve and filter AD users
$FilteredUsers = Get-ADUser -Filter {
    title -eq '*trainee*' -and enabled -eq $true
} -Property whencreated, canonicalname, enabled | 
    Where-Object { $_.whencreated -lt $DateThreshold } |
    Select-Object name, userprincipalname, whencreated, canonicalname, enabled | 
    Sort-Object whencreated

    $FilteredUsers
# Convert filtered users to HTML table
$HtmlTable = "<table border='1'>
<tr>
<th>Name</th>
<th>User Principal Name</th>
<th>When Created</th>
<th>Canonical Name</th>
<th>Enabled</th>
</tr>"

foreach ($user in $FilteredUsers) {
    $HtmlTable += "<tr>
    <td>$($user.name)</td>
    <td>$($user.userprincipalname)</td>
    <td>$($user.whencreated)</td>
    <td>$($user.canonicalname)</td>
    <td style='background-color:red;'>$($user.enabled)</td>
    </tr>"
}

$HtmlTable += "</table>"

# Define email parameters
$SmtpServer = "mail.domain.com"
$From = "snd@domain.com"
$To =  'rcp@domain.com'
$Subject = "AD Intern Users Report"
$Body = @"
<html>
<body>
<h2>These intern users are enabled for more than 3 months</h2>
$HtmlTable
</body>
</html>
"@

# Send the email
Send-MailMessage -SmtpServer $SmtpServer -port 587 -From $From -To $To -Subject $Subject -Body $Body -BodyAsHtml
