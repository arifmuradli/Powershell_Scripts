# Get pagefile usage information
$pagefile = Get-CimInstance -ClassName Win32_PageFileUsage

foreach ($pf in $pagefile) {
    # Calculate the usage percentage
    $usagePercentage = [math]::Round(($pf.CurrentUsage / $pf.AllocatedBaseSize) * 100, 2)
    
    # Display the results
    $result = [PSCustomObject]@{
        PageFilePath       = $pf.Name
        AllocatedBaseSizeGB = [math]::Round($pf.AllocatedBaseSize / 1024, 2)
        CurrentUsageGB      = [math]::Round($pf.CurrentUsage / 1024, 2)
        UsagePercentage     = $usagePercentage
    }

    Write-Output $result
    
    # Check if usage percentage is above 60%
    if ($usagePercentage -gt 60) {
        Write-Output "Pagefile usage is above 60%. Restarting the computer..."
        Restart-Computer -Force
    }
}
