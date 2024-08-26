''' replace path for exe application from this folder "\\Powershell_Scripts\DiskSpace\DiskSpace.exe"
' Define the critical disk space percentage threshold
Const percentCritical = 10

' Loop indefinitely
Do
    ' Create a WMI object to query disk information
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colDisks = objWMIService.ExecQuery("Select * from Win32_LogicalDisk Where DeviceID='C:'")

    ' Iterate through the disks
    For Each objDisk in colDisks
        ' Calculate free space in GB
        DiskFreeSpace = objDisk.FreeSpace / 1073741824 ' Convert bytes to GB

        ' Calculate free space percentage
        DiskFreeSpacePercent = Round((objDisk.FreeSpace / objDisk.Size) * 100, 2)

        ' Check if free space percentage is below the critical threshold
        If DiskFreeSpacePercent < percentCritical Then
            ' Check if the process diskspace.exe is running
            Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
            Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process Where Name='diskspace.exe'")
            
            If colProcesses.Count = 0 Then
                ' Execute the specified executable if diskspace.exe is not running
                Set objShell = CreateObject("WScript.Shell")
                objShell.Run "\\Powershell_Scripts\DiskSpace\DiskSpace.exe"
            End If
        End If
    Next

    ' Pause execution for 30 minutes (in milliseconds)
    WScript.Sleep 1800000 ' 30 minutes in milliseconds

Loop ' Repeat the loop indefinitely
