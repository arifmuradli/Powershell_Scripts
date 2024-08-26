# Import the Active Directory module if not already loaded
Import-Module ActiveDirectory

# Get a list of all enabled computer objects in the domain
$computers = Get-ADComputer -Filter {Enabled -eq $true}

# Create an array to store the results
$results = @()

# Loop through each enabled computer and retrieve its time zone information
foreach ($computer in $computers) {
    $computerName = $computer.Name
    $timeZone = Invoke-Command -ComputerName $computerName -ScriptBlock {
        Get-TimeZone
    }

    # Create an object to store the computer name and time zone information
    $result = [PSCustomObject]@{
        ComputerName = $computerName
        TimeZone = $timeZone.Id
    }

    # Add the result to the array
    $results += $result
}

# Export the results to a CSV file
$results | Export-Csv -Path "TimeZoneInfo.csv" -NoTypeInformation
