# Retrieve the most recent event with event code 34
$Error34 = Get-WmiObject -Query "SELECT * FROM Win32_NTLogEvent WHERE Logfile = 'Application' AND SourceName = 'microsoft-windows-OnlineResponder' and eventcode = '34'" |
           Sort-Object TimeGenerated -Descending |
           Select-Object -First 1

# Convert the TimeGenerated property to a human-readable date
$ReadableDate = [Management.ManagementDateTimeConverter]::ToDateTime($Error34.TimeGenerated)

# Compose the email body in HTML format with some CSS
$Body = @"
<html>
<head>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
            font-family: Arial, sans-serif;
        }
        th, td {
            border: 1px solid #dddddd;
            text-align: left;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        h2 {
            color: #2e6da4;
        }
    </style>
</head>
<body>
    <h2>Online Responder Alert: Event 34</h2>
    <table>
        <tr>
            <th>Server</th>
            <td>$($Error34.ComputerName)</td>
        </tr>
        <tr>
            <th>Event Message</th>
            <td>$($Error34.Message)</td>
        </tr>
        <tr>
            <th>Event Time</th>
            <td>$ReadableDate</td>
        </tr>
    </table>
</body>
</html>
"@

# Send the email
Send-MailMessage -port 587 -To "xxx@xxx.az" `
                 -From "xxx@xxx.az" `
                 -Subject "Latest Event 34 from Online Responder" `
                 -Body $Body `
				 -bodyashtml `
                 -SmtpServer "mail.xxx.az"
