# Get total and free memory
$totalMem = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize
$freeMem = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory

# Calculate RAM usage percentage
$usedMem = $totalMem - $freeMem
$ramUsage = [math]::Round(($usedMem / $totalMem) * 100, 2)

# Display RAM usage
Write-Host "RAM Usage: $ramUsage%"
