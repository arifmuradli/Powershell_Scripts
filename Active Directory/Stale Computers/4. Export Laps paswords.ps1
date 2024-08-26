### For extra safety, you can backup LAPS passwords for local administrator accounts
# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the OU distinguished name
$ouDistinguishedName = "OU=DisabledServers,DC=domain,DC=local"

# Get all computer objects under the specified OU
$computers = Get-ADComputer -Filter * -SearchBase $ouDistinguishedName -Properties *

# Specify the path for exporting the attributes to a CSV file
$exportPath = "C:\lapspasswordbackup.csv"

# Create an array to store computer objects with selected properties
$exportData = @()

# Loop through each computer object
foreach ($computer in $computers) {
    # Retrieve LAPS password if available
    $lapsPassword = $computer.'ms-Mcs-AdmPwd'

    # Create a custom object with selected properties
    $exportObject = [PSCustomObject]@{
        'Name'                  = $computer.Name
        'DistinguishedName'     = $computer.DistinguishedName
        'OperatingSystem'       = $computer.OperatingSystem
        'LastLogonDate'         = $computer.LastLogonDate
        'LAPS_Password'         = $lapsPassword
        # Add more properties as needed
    }

    # Add the object to the export array
    $exportData += $exportObject
}

# Export the attributes to a CSV file
$exportData | Export-Csv -Path $exportPath -NoTypeInformation

Write-Host "Attributes of computers under the OU exported to $exportPath"
