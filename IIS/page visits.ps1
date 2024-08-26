#Replace $searchString with the homepage
# Set the path to your IIS log files directory
$logPath = "C:\inetpub\logs\LogFiles\W3SVC1"

# Set the URL you want to search for
$searchString = "/homapage/default.aspx"

# Get all log files in the directory
$logFiles = Get-ChildItem -Path $logPath -Filter *.log

# Initialize a hashtable to store the results
$results = @{}

# Loop through each log file and count the occurrences of the search string
foreach ($logFile in $logFiles) {
    # Read the log file content
    $content = Get-Content -Path $logFile.FullName
    
    # Count the occurrences of the search string in the content
    $count = ($content | Select-String -Pattern $searchString).Count
    
    # Add the count to the hashtable with the log file name as the key
    $results[$logFile.Name] = $count
}

# Output the results
foreach ($result in $results.GetEnumerator()) {
    Write-Output "$($result.Key) : $($result.Value)"
}
