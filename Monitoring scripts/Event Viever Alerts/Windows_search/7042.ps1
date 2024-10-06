$Error7042 = Get-CimInstance -Query "SELECT * FROM Win32_NTLogEvent WHERE Logfile = 'Application' AND SourceName = 'microsoft-windows-search' and eventcode = '7042'" |
           Sort-Object TimeGenerated -Descending |
           Select-Object -First 1
		   
# Convert the TimeGenerated property to a human-readable date
#$ReadableDate = [Management.ManagementDateTimeConverter]::ToDateTime($Error7042.TimeGenerated)

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
            color: #FF0000;
        }
    </style>
</head>
<body>
    <h2>Windows Search Alert: Event 7042</h2>
    <table>
        <tr>
            <th>Server</th>
            <td>$($Error7042.ComputerName)</td>
        </tr>
        <tr>
            <th>Event Message</th>
            <td>$($Error7042.Message)</td>
        </tr>
        <tr>
            <th>Event Time</th>
            <td>$($Error7042.TimeGenerated)</td>
        </tr>
    </table>
</body>
</html>
"@

# Send the email
Send-MailMessage -port 587 -To "xxx@xxx.az" `
                 -From "xxx@xxx.az" `
                 -Subject "Latest Event 23 from Online Responder" `
                 -Body $Body `
                 -bodyashtml `
                 -SmtpServer "mail.xxx.az"
