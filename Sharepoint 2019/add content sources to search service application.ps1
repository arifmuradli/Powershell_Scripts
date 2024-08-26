### You need to define your Search Service Application before running this script, for me it is 'Search Service Application 1'


# Define the content sources
$contentSources = @(
    @{
        Name = "Folder1"
        Location = "\\localfileserver\Folder1"
    },
    @{
        Name = "Folder2"
        Location = "\\localfileserver\Folder2"
    },
    #................
	#,
    @{
        Name = "FolderN"
        Location = "\\localfileserver\FolderN"
    }
)   


# Load SharePoint PowerShell snap-in if it's not already loaded
if ((Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin Microsoft.SharePoint.PowerShell
}

# Get the Search Service Application
$searchServiceApp = Get-SPServiceApplication -name 'Search Service Application 1'

if ($searchServiceApp -eq $null) {
    Write-Error "Search Service Application not found."
    exit
}

# Loop through each content source and create it
foreach ($source in $contentSources) {
    $sourceName = $source.Name
    $sourceLocation = $source.Location

    # Check if the content source already exists
    $existingSource = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication $searchServiceApp | Where-Object { $_.Name -eq $sourceName }

    if ($existingSource) {
        Write-Output "Content Source '$sourceName' already exists."
    } else {
        # Create a new content source
        New-SPEnterpriseSearchCrawlContentSource -SearchApplication $searchServiceApp -Name $sourceName -Type 'File' -StartAddresses $sourceLocation
        Write-Output "Content Source '$sourceName' created with location '$sourceLocation'."
    }
}

Write-Output "Content sources have been configured."

