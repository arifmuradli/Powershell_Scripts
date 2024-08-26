# Define the path to the folder containing the MSI files
$folderPath = "\\fileserver\soft\Minimal Requirement\"

# Get all MSI files in the specified folder
$applications = Get-ChildItem -Path $folderPath -Filter *.msi | ForEach-Object {
    [PSCustomObject]@{ Name = $_.BaseName; Path = $_.FullName }
}

# Display the list of applications in a grid view and allow the user to select multiple applications
$selectedApps = $applications | Out-GridView -PassThru -Title "Select Applications to Install"
# Check if any applications were selected
if ($selectedApps -ne $null) {
    foreach ($app in $selectedApps) {
        Write-Host "Installing $($app.Name)..."
        # Install the application using Start-Process
        Start-Process msiexec.exe -ArgumentList "/i `"$($app.Path)`" /quiet /norestart" -Wait
        Write-Host "$($app.Name) installation complete."
    }
} else {
    Write-Host "No applications were selected."
}
