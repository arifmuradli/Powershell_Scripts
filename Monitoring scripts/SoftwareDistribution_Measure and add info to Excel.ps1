# Import Active Directory module
Import-Module ActiveDirectory

# Define the OU to monitor
$OU = "OU=Computers,DC=domain,DC=local"  # Update this with the appropriate OU for your environment

# Get all computers within the specified OU
$computers = Get-ADComputer -Filter * -SearchBase "$OU" | Select-Object -ExpandProperty Name

# Define the output Excel file path
$outputFilePath = "C:\SoftwareDist_allSize.xlsx"

# Create a new Excel workbook
$excel = New-Object -ComObject Excel.Application
$workbook = $excel.Workbooks.Add()
$sheet = $workbook.Worksheets.Add()
$sheet.Name = "SoftwareDistribution"
$row = 1

# Add headers to the Excel sheet
$sheet.Cells.Item($row, 1) = "Computer Name"
$sheet.Cells.Item($row, 2) = "Software Distribution Folder Size (GB)"
$row++

# Loop through each computer and get the size of the software distribution folder
foreach ($computer in $computers) {
    # Get the software distribution folder size for each computer
    $folderPath = "\\$computer\C$\Windows\SoftwareDistribution"
    $folderSizeGB = "{0:N2}" -f ((Get-ChildItem $folderPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB)

    # Write computer name and folder size to Excel
    $sheet.Cells.Item($row, 1) = $computer
    $sheet.Cells.Item($row, 2) = $folderSizeGB
    $row++
}

# Autofit columns for better readability
$usedRange = $sheet.UsedRange
$usedRange.EntireColumn.AutoFit() | Out-Null

# Save the Excel file and close Excel
$workbook.SaveAs($outputFilePath)
$excel.Quit()

# Release Excel COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
Remove-Variable excel, workbook, sheet

Write-Host "Script execution completed. Output Excel file saved to: $outputFilePath"
