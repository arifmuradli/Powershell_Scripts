### This is the main part of the script, if duplicate serial numbers are identified, it sends notification for further investigation

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the Organizational Unit to search
$ou = "OU=Computers,DC=domain,DC=local"

# Get all computers in the specified OU with the serialNumber and whenCreated attributes
$computers = Get-ADComputer -Filter { serialNumber -like '*' } -SearchBase $ou -Properties serialNumber, whenCreated

# Filter out unique serial numbers
$uniqueSerials = $computers.serialNumber | Sort-Object -Unique

# Initialize an empty array to store computers with duplicate serial numbers
$duplicateComputers = @()

# Iterate over each unique serial number
foreach ($serial in $uniqueSerials) {
    # Get computers with the current serial number
    $computersWithSerial = $computers | Where-Object { $_.serialNumber -eq $serial }
    # If more than one computer has the same serial number, add them to $duplicateComputers
    if ($computersWithSerial.Count -gt 1) {
        $duplicateComputers += $computersWithSerial
    }
}

# Check for duplicates and prepare output
if ($duplicateComputers.Count -gt 0) {
    # Prepare text before the table
    $preTableText = "The following computers have duplicate serial numbers in Active Directory:<br><br>"

    # Prepare HTML table
    $htmlTable = "<table border='1'><tr><th>Computer Name</th><th>Serial Number</th><th>When Created</th></tr>"
    $duplicateComputers | Sort-Object serialNumber | ForEach-Object {
        $htmlTable += "<tr><td>$($_.Name)</td><td>$($_.serialNumber)</td><td>$($_.whenCreated)</td></tr>"
    }
    $htmlTable += "</table>"

    # Prepare text after the table with bold and red color
$postTableText = "<br><b><span style='color:grey; font-size: 16pt;'>Please delete old computers from Active Directory.</span></b><br><b><span style='color:red; font-size: 20pt;'>Xahish olunur, kohne tarixli komputeri AD-den silin.</span></b>"

    # Combine the text and table into the email body
    $Body = $preTableText + $htmlTable + $postTableText

    # Email settings
    $smtpServer = "mail.domain.az"
$smtpPort = 587  # Replace with your SMTP server port if different
$smtpFrom = "xxx@domain.az"
$smtpTo = "xxx1@domain.az", "xxx2@domain.az"
    $Subject = "Duplicate Serial Numbers Detected"

    # Create the email message
    $SMTPMessage = @{
        From       = $SMTPFrom
        To         = $SMTPTo
        Subject    = $Subject
        Body       = $Body
        BodyAsHtml = $true
        SmtpServer = $SMTPServer
        Port       = $SMTPPort
    }

    # Send the email
    Send-MailMessage @SMTPMessage
} else {
    Write-Output "No duplicate serial numbers found in AD computers."
}
