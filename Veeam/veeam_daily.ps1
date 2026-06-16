# === Veeam Daily Backup Report via SQL – Always Sent to Teams ===
# Fast SQL version using Backup.Model.JobSessions
# This is supposed to run on Veeam hosting machine with system permissions on DB. 
# === CONFIG ===
$webhookUrl    = "https://webhook.proxy.local:6443/veeam"  # ← CHANGE THIS
$lookbackHours = 24
$hostname      = $env:COMPUTERNAME

# === Veeam SQL Database Connection ===
# Change these values according to your environment
$sqlServer   = "database.domain.local"           # e.g. "veeam-sql01" or "localhost"
$database    = "VeeamBackup"                     # Most common name; sometimes VeeamBackup_SERVERNAME
$connectionString = "Server=$sqlServer;Database=$database;Integrated Security=True;"

# SQL Query – finished jobs in last 24 hours
$sqlQuery = @"
SELECT 
    js.job_name                          AS JobName,
    CASE js.job_type
        WHEN 0     THEN 'Backup'
        WHEN 12000 THEN 'Windows Agent Backup'
        WHEN 12002 THEN 'Windows Agent Policy'
        WHEN 12005 THEN 'Rescan'
        WHEN 4000  THEN 'Windows Agent Backup (legacy)'
        WHEN 27    THEN 'Tape Inventory'
        WHEN 28    THEN 'Backup to Tape'
        WHEN 24    THEN 'File to Tape Backup'
        WHEN 13000 THEN 'File Backup'
        ELSE CAST(js.job_type AS varchar(10)) + ' (unknown)'
    END                                  AS JobType,
    js.creation_time                     AS CreationTime,
    js.end_time                          AS EndTime,
    CASE js.result
        WHEN 0 THEN 'Success'
        WHEN 1 THEN 'Warning'
        WHEN 2 THEN 'Failed'
        ELSE 'Other (' + CAST(js.result AS varchar(5)) + ')'
    END                                  AS Result
FROM 
    "Backup.Model.JobSessions" js WITH (NOLOCK)
WHERE 
    js.end_time >= DATEADD(HOUR, -24, GETDATE())
    AND js.end_time IS NOT NULL
    AND js.job_type NOT IN (19, 21, 12003, 12006, 502, 10000, 10001, 22000, 23000, 31000, 32000)
ORDER BY 
    CASE js.result
        WHEN 2 THEN 1    -- Failed first
        WHEN 1 THEN 2    -- Warning
        WHEN 0 THEN 3    -- Success
        ELSE 4
    END,
    js.end_time DESC;
"@

# === Execute SQL Query ===
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $sqlQuery

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $null = $adapter.Fill($dataset)

    $sessions = $dataset.Tables[0]
    $connection.Close()
}
catch {
    Write-Warning "SQL query failed: $($_.Exception.Message)"
    exit
}

# === No sessions at all ===
if ($sessions.Rows.Count -eq 0) {
    $summaryText = "No backup jobs finished in the last $lookbackHours hours."
    $headerEmoji = "&#x2139;&#xFE0F;"          # ℹ️
    $headerColor = "#0078D4"
    $headerText  = "<b>$headerEmoji No Backup Activity – $hostname</b>"
}
else {
    # === Summary calculation ===
    $totalFinished = $sessions.Rows.Count
    $failedCount   = ($sessions.Select("Result = 'Failed'")).Count
    $warningCount  = ($sessions.Select("Result = 'Warning'")).Count
    $successCount  = ($sessions.Select("Result = 'Success'")).Count

    $summaryText = "In last $lookbackHours hours, $totalFinished job$(if($totalFinished -ne 1){'s'}) finished."
    if ($failedCount -gt 0)   { $summaryText += " <b>$failedCount failed" }
    if ($warningCount -gt 0)  { $summaryText += " $warningCount warnings." }
    if ($successCount -gt 0 -and $failedCount -eq 0 -and $warningCount -eq 0) {
        $summaryText += " <b>All successful.</b>"
    }

    # Header based on worst status
    if ($failedCount -gt 0) {
        $headerEmoji = "&#x1F6A8;"      # 🚨
        $headerColor = "#DC3545"        # Red
        $headerText  = "<b>$headerEmoji Veeam Backup PROBLEMS Detected – $hostname</b>"
    }
    elseif ($warningCount -gt 0) {
        $headerEmoji = "&#x26A0;&#xFE0F;"  # ⚠️
        $headerColor = "#FFC107"           # Yellow
        $headerText  = "<b>$headerEmoji Veeam Backup Warnings – $hostname</b>"
    }
    else {
        $headerEmoji = "&#x2705;"          # ✅
        $headerColor = "#28A745"           # Green
        $headerText  = "<b>$headerEmoji Veeam Backup Report – All Good – $hostname</b>"
    }
}

# === Build HTML table with inline styles ===
$htmlHeader = @"
<table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse; font-family: Calibri, Arial, sans-serif; width: 100%;">
<tr style="background-color: #4CAF50; color: white;">
    <th>Job Name</th>
    <th>Job Type</th>
    <th>Start Time</th>
    <th>End Time</th>
    <th>Result</th>
</tr>
"@

$htmlBody = foreach ($row in $sessions.Rows) {
    $rowStyle = switch ($row["Result"]) {
        "Success" { "background-color: #d4edda; color: #155724;" }
        "Warning" { "background-color: #fff3cd; color: #856404;" }
        "Failed"  { "background-color: #f8d7da; color: #721c24; font-weight: bold;" }
        default   { "background-color: #f9f9f9; color: #333;" }
    }

    "<tr style='$rowStyle'>"
    "<td>$($row["JobName"])</td>"
    "<td>$($row["JobType"])</td>"
    "<td>$($row["CreationTime"].ToString('yyyy-MM-dd HH:mm:ss'))</td>"
    "<td>$($row["EndTime"].ToString('yyyy-MM-dd HH:mm:ss'))</td>"
    "<td>$($row["Result"])</td>"
    "</tr>"
}

$tableContent = $htmlHeader + ($htmlBody -join "") + "</table>"

# === Final Teams message ===
$teamsMessage = @"
$headerText<br><br>
<span style="color: $headerColor; font-weight: bold;">$summaryText</span><br><br>
$tableContent
"@

$payload = @{ text = $teamsMessage } | ConvertTo-Json -Depth 10

try {
    Invoke-RestMethod -Method Post -Uri $webhookUrl -Body $payload -ContentType "application/json"
    Write-Output "Daily Veeam report sent to Teams."
}
catch {
    Write-Warning "Failed to send Teams report: $($_.Exception.Message)"
}
