### This script will run Full Crawl for the IDs, from 47 to 185 (You can modify numbers or just remove that part)
# Load SharePoint PowerShell snap-in if not already loaded
if ((Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin Microsoft.SharePoint.PowerShell
}

# Get the Search Service Application
$searchApp = Get-SPEnterpriseSearchServiceApplication -Identity "Search Service Application 1"

# Retrieve Content Sources
$contentSources = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication $searchApp

# Function to start full crawl
function Start-FullCrawl {
    param (
        [int]$contentSourceId
    )

    $contentSource = $contentSources | Where-Object { $_.Id -eq $contentSourceId }

    if ($contentSource -ne $null) {
        Write-Host "Starting full crawl for content source ID $contentSourceId..."
        $contentSource.StartFullCrawl()
    } else {
        Write-Host "Content source with ID $contentSourceId not found."
    }
}

# Loop through the range of content source IDs and start the crawl
for ($id = 47; $id -le 185; $id++) {
    Start-FullCrawl -contentSourceId $id
}

