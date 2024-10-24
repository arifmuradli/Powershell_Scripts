# Define the OUs to search
$ouList = @(
    "OU=Servers,DC=testaccessbank,DC=local",
    "OU=Domain Controllers,DC=testaccessbank,DC=local",
    "OU=All_computers,DC=testaccessbank,DC=local"
)

# Initialize an empty array to store servers
$servers = @()

# Loop through each OU and collect the list of servers
foreach ($ou in $ouList) {
    $servers += Get-ADComputer -SearchBase $ou -Filter * | Select-Object -ExpandProperty Name
}

# Function to get disk space information
function Get-DiskSpace {
    param (
        [string]$ComputerName
    )
    try {
        $disks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3" | Select-Object DeviceID, Size, FreeSpace
        return $disks
    } catch {
        Write-Warning "Failed to retrieve disk information for $ComputerName"
        return $null
    }
}

# Collect disk space information for each server
$diskSpaceInfo = @()
$serversNotInContact = @()
foreach ($server in $servers) {
    $disks = Get-DiskSpace -ComputerName $server
    if ($disks) {
        foreach ($disk in $disks) {
            $totalSpaceGB = [math]::Round($disk.Size / 1GB, 2)
            $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            $freeSpacePct = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
            $diskSpaceInfo += [PSCustomObject]@{
                ComputerName = $server
                DeviceID     = $disk.DeviceID
                TotalSpaceGB = $totalSpaceGB
                FreeSpaceGB  = $freeSpaceGB
                FreeSpacePct = $freeSpacePct
            }
        }
    } else {
        $serversNotInContact += $server
    }
}

# Sort disk space info by ComputerName
$diskSpaceInfo = $diskSpaceInfo | Sort-Object ComputerName

# Summary data
$totalServers = $servers.Count
$criticalServers = ($diskSpaceInfo | Where-Object { $_.FreeSpacePct -lt 5 }).Count
$warningServers = ($diskSpaceInfo | Where-Object { $_.FreeSpacePct -lt 10 -and $_.FreeSpacePct -ge 5 }).Count
$normalServers = ($diskSpaceInfo | Where-Object { $_.FreeSpacePct -ge 10 }).Count

# Generate HTML content with JavaScript for sorting
$htmlContent = @"
<html>
<head>
    <title>Server Disk Space Report</title>
    <style>
        table { width: auto; border-collapse: collapse; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; white-space: nowrap; }
        th { background-color: #f2f2f2; cursor: pointer; }
        th.sortable::after { content: ' \2195'; }
        th.sort-asc::after { content: ' \2191'; }
        th.sort-desc::after { content: ' \2193'; }
        .low-space { background-color: yellow; }
        .critical-space { background-color: red; }
    </style>
    <script>
        function sortTable(n) {
            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
            table = document.getElementById("diskTable");
            switching = true;
            dir = "asc"; 
            resetSortIcons(n);
            while (switching) {
                switching = false;
                rows = table.rows;
                for (i = 1; i < (rows.length - 1); i++) {
                    shouldSwitch = false;
                    x = rows[i].getElementsByTagName("TD")[n];
                    y = rows[i + 1].getElementsByTagName("TD")[n];
                    if (dir == "asc") {
                        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                            shouldSwitch = true;
                            break;
                        }
                    } else if (dir == "desc") {
                        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                            shouldSwitch = true;
                            break;
                        }
                    }
                }
                if (shouldSwitch) {
                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                    switching = true;
                    switchcount ++;      
                } else {
                    if (switchcount == 0 && dir == "asc") {
                        dir = "desc";
                        switching = true;
                    }
                }
            }
            if (dir == "asc") {
                document.getElementById("header" + n).classList.add("sort-asc");
            } else {
                document.getElementById("header" + n).classList.add("sort-desc");
            }
        }

        function resetSortIcons(n) {
            var headers = document.getElementsByTagName("th");
            for (var i = 0; i < headers.length; i++) {
                if (i != n) {
                    headers[i].classList.remove("sort-asc");
                    headers[i].classList.remove("sort-desc");
                }
            }
        }
    </script>
</head>
<body>
    <h2>Server Disk Space Report</h2>
    <p>Total Disks monitored: $totalServers</p>
    <p>Disks with critical state (free space < 5%): $criticalServers</p>
    <p>Disks with warning state (free space < 10%): $warningServers</p>
    <p>Disks in normal condition (more than 10% free space ): $normalServers</p>
    <p>Servers not in contact: $($serversNotInContact.Count)</p>
    <ul>
"@

# Add the list of servers not in contact to HTML content
foreach ($server in $serversNotInContact) {
    $htmlContent += "<li>$server</li>"
}

$htmlContent += @"
    </ul>
    <table id="diskTable">
        <tr>
            <th id="header0" class="sortable" onclick="sortTable(0)">Computer Name</th>
            <th id="header1" class="sortable" onclick="sortTable(1)">Device ID</th>
            <th id="header2" class="sortable" onclick="sortTable(2)">Total Space (GB)</th>
            <th id="header3" class="sortable" onclick="sortTable(3)">Free Space (GB)</th>
            <th id="header4" class="sortable" onclick="sortTable(4)">Free Space (%)</th>
        </tr>
"@

# Append disk space information to HTML content
foreach ($disk in $diskSpaceInfo) {
    $freeSpaceClass = ""
    if ($disk.FreeSpacePct -lt 5) {
        $freeSpaceClass = "critical-space"
    } elseif ($disk.FreeSpacePct -lt 10) {
        $freeSpaceClass = "low-space"
    }
    $htmlContent += "<tr class='$freeSpaceClass'>
        <td>$($disk.ComputerName)</td>
        <td>$($disk.DeviceID)</td>
        <td>$($disk.TotalSpaceGB)</td>
        <td>$($disk.FreeSpaceGB)</td>
        <td>$($disk.FreeSpacePct)%</td>
    </tr>"
}

# Close HTML tags
$htmlContent += @"
    </table>
</body>
</html>
"@

# Save the HTML report
$reportPath = "D:\ServerDiskSpaceReport.html"
$htmlContent | Out-File -FilePath $reportPath -Encoding UTF8

# Output the path to the report
"Report saved to $reportPath"
