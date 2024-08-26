### Run this task from Task Scheduler

# Get all session IDs
$sessions = quser | ForEach-Object { ($_ -split '\s+')[2] }

# Log off all session IDs
foreach ($sessionID in $sessions) {
    logoff $sessionID
}
