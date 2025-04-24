$ipAddress = "10.1.1.2"
$maskBits = 24
$ipType = "IPv4"

# Fetch the wired NIC
$adapter = Get-NetAdapter | Where-Object { $_.Name -match "Ethernet*" }

# Remove the current IPv4 address from the NIC
if (($adapter | Get-NetIPConfiguration).IPv4Address.IPv4Address) {
    $adapter | Remove-NetIPAddress -AddressFamily $ipType -Confirm:$false
}

# Remove the current IPv4 gateway from the NIC
if (($adapter | Get-NetIPConfiguration).IPv4DefaultGateway) {
    $adapter | Remove-NetRoute -AddressFamily $ipType -Confirm:$false
}

# Set the specified static IPv4 info on the NIC
$adapter | New-NetIPAddress -AddressFamily $ipType -IPAddress $ipAddress -PrefixLength $maskBits