### API must be configured separately.
### If stateis not idle, Script will try for 5 times each with 5 minututes
# Get the local computer's hostname
$ComputerName = $env:COMPUTERNAME

# Set the API endpoint
$url = "http://$computerName"+":5001/api/status"

# Initialize the counter
$counter = 0

# Define the maximum number of retries
$maxRetries = 5

# Set the local path for log files
$localLogPath = "C:\Restart\Logs"

# Set the UNC path for log files
$uncPath = "\\fileserver\Restart_Logs"

# Get the current date
$currentDate = (Get-Date).ToString("ddMMyyyy")

# Generate the base log file name
$baseLogName = "${currentDate}_${ComputerName}"

# Initialize the log file index
$logIndex = 0
$logFile = "${localLogPath}\${baseLogName}.log"

# Check if the log file already exists and generate a unique name if necessary
while (Test-Path $logFile) {
    $logIndex++
    $logFile = "${localLogPath}\${baseLogName} ($logIndex).log"
}

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    Add-Content -Path $logFile -Value "$((Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) - $message"
}

# Log the start of the script
Log-Message "Script started."

try {
    # Loop until the state is idle or the maximum number of retries is reached
    while ($counter -lt $maxRetries) {
        # Send GET request to the API
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing
        $jsonResponse = $response.Content | ConvertFrom-Json

        # Check the state
        if ($jsonResponse.State -eq "idle") {
            # Log idle state message
            Log-Message "State is idle. Initiating restart..."

            # Restart the remote computer if the state is idle
            Restart-Computer -ComputerName $computerName -Force

            # Log restart message
            Log-Message "Restart command has been sent to the remote computer."

            break
        } else {
            # Increment the counter if the state is busy
            $counter++

            # Log busy state message
            Log-Message "State is busy, retry will be in 5 minutes...."

            # Wait for 5 minutes before rechecking
            Start-Sleep -Seconds 300
        }
    }

    # Log the result if the state remained busy for 5 times
    if ($counter -eq $maxRetries) {
        Log-Message "State remained busy for $maxRetries times. Stopping the pipeline."
    }
} catch {
    # Log any errors
    Log-Message "Error: $_"
}

# Log the end of the script
Log-Message "Script ended."

# Copy the log file to the UNC path
Copy-Item -Path $logFile -Destination $uncPath
