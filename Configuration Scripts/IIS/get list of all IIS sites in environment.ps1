# Import the necessary modules
Import-Module ActiveDirectory

# Define the Organizational Unit (OU) you want to search
$ou = "OU=servers,DC=domain,DC=local"

# Retrieve all computers from the specified OU
$computers = Get-ADComputer -Filter * -SearchBase $ou -Property Name, IPv4Address | Select-Object Name, IPv4Address

# Initialize an array to store the results
$results = @()

# Iterate through each computer
foreach ($computer in $computers) {
    try {
        # Create a remote session to the computer
        $session = New-PSSession -ComputerName $computer.Name -ErrorAction Stop
        
        # Get the list of IIS sites and their states
        $iisSites = Invoke-Command -Session $session -ScriptBlock {
            Import-Module WebAdministration
            Get-Website | Select-Object Name, State
        }

        # Add the results to the array
        foreach ($site in $iisSites) {
            $results += [PSCustomObject]@{
                ComputerName = $computer.Name
                IPAddress    = $computer.IPv4Address
                SiteName     = $site.Name
                State        = $site.State
            }
        }

        # Remove the remote session
        Remove-PSSession -Session $session
    }
    catch {
        Write-Host "Could not connect to $($computer.Name)"
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path C:\iissites.csv -NoTypeInformation

# Output the results (optional, if you want to display them in the console as well)
$results | Format-Table -AutoSize
