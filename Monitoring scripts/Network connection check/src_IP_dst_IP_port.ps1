$sourceIP = "192.168.XXX.XXX"
$destinationIP = "192.168.XXX.XXX"
$destinationPort = 443

try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect($destinationIP, $destinationPort)
    
    if ($tcpClient.Connected) {
        Write-Host ("Connection from " + $sourceIP + " to " + $destinationIP + ":" + $destinationPort + " successful")
    } else {
        Write-Host ("Connection from " + $sourceIP + " to " + $destinationIP + ":" + $destinationPort + " failed")
    }
} catch {
    Write-Host ("Error: " + $_.Exception.Message)
} finally {
    if ($tcpClient -ne $null) {
        $tcpClient.Close()
    }
}
