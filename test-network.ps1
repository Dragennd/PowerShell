#Requires -Version 7.0

## Initialize global variables
$ipAddresses = @()
$counter = 0
$mtrTestResults = @{}
$percentComplete = 0
$consoleWidth = $Host.UI.RawUI.WindowSize.Width
$currentDate = Get-Date -Format "MM-dd-yy -- HHmm"
$ipInfo = get-netipconfiguration | Where-Object { $_.netadapter.status -ne "Disconnected" }

## Setup the file structure and verify nothing is missing
$resultPath = "C:\BWIT\Network Test Log $currentDate.txt"
if (!(Test-Path -Path $($resultPath.Split("\"))[0][1])) { New-Item -Path $($resultPath.Split("\"))[0][1] -ItemType Directory }
New-Item -Path $resultPath -ItemType File

## Display the header on the console
Clear-Host
Write-Output $('-' * $consoleWidth -join '')
Write-Output "     $($psstyle.Foreground.BrightCyan)Network Test Script$($psstyle.Reset)"
Write-Output $('-' * $consoleWidth -join '')
Write-Output ""
Write-Output "$($psstyle.Foreground.Green)Default Gateway    :$($psstyle.Reset) $($ipInfo.IPv4DefaultGateway.NextHop)"
Write-Output "$($psstyle.Foreground.Green)Current IP Address :$($psstyle.Reset) $($ipInfo.IPv4Address.IPAddress)"
Write-Output ""

## Specify the IP Addresses to be tested
Write-Output "$($psstyle.Foreground.Green)Please enter the IP Address(s) you want tested. If more than one, separate them with a comma.$($psstyle.Reset)"
$ipAddresses = Read-Host " "
$ipAddresses = $ipAddresses.Split(",").Trim()
Write-Output ""

## Specify the duration of the test
Write-Output "$($psstyle.Foreground.Green)Enter the duration (in minutes) that you want the test to be performed.$($psstyle.Reset)"
$mtrDuration = Read-Host " "
$mtrDuration = [System.Math]::Round($mtrDuration)
$mtrDuration = ([int]$mtrDuration * 60)
Clear-Host

############################
# Perform the Network Test #
############################
do {
    Clear-Host
    [console]::CursorVisible = $false

    foreach ($ipAddress in $ipAddresses) {   
        ## Initialize the first run for every IP Address
        if (!($mtrTestResults.$ipAddress)) {
            $mtrTestResults.$ipAddress = @{}
            ($mtrTestResults.$ipAddress).FirstRun = $true
            ($mtrTestResults.$ipAddress).PacketsLost = 0
        }
        
        ## Perform the connection test
        $connResults = Test-Connection -TargetName $ipAddress -IPv4 -Count 1

        ## Check if the packet failed to return
        if ($connResults.Status -eq "TimedOut") {
            ($mtrTestResults.$ipAddress).PacketsLost = ($mtrTestResults.$ipAddress).PacketsLost + 1
            continue
        }

        ## Perform the first run of the connection test
        if (($mtrTestResults.$ipAddress).FirstRun -eq $true) {
            ($mtrTestResults.$ipAddress).LowestPing = $connResults.Latency
            ($mtrTestResults.$ipAddress).HighestPing = $connResults.Latency
            ($mtrTestResults.$ipAddress).AveragePing = $connResults.Latency
            ($mtrTestResults.$ipAddress).FirstRun = $false
            continue
        }

        ## Set the average ping
        ($mtrTestResults.$ipAddress).AveragePing += $connResults.Latency

        ## Set the lowest ping
        if ($connResults.Latency -le ($mtrTestResults.$ipAddress).LowestPing) {
            ($mtrTestResults.$ipAddress).LowestPing = $connResults.Latency
            continue
        }

        ## Set the highest ping
        if ($connResults.Latency -ge ($mtrTestResults.$ipAddress).HighestPing) {
            ($mtrTestResults.$ipAddress).HighestPing = $connResults.Latency
            continue
        }
    }

    $counter++
    $percentComplete = [int](($counter / $mtrDuration) * 100)

    ## Display the header on the console
    Write-Output $('-' * $consoleWidth -join '')
    Write-Output "     $($psstyle.Foreground.BrightCyan)Performing Network Test$($psstyle.Reset)"
    Write-Output $('-' * $consoleWidth -join '')
    Write-Output ""
    Write-Output "$($psstyle.Foreground.Green)Total Test Duration :$($psstyle.Reset) $($mtrDuration / 60) Minute(s)"
    Write-Output "$($psstyle.Italic)$($psstyle.Foreground.BrightYellow)$percentComplete%$($psstyle.Reset) $($psstyle.Foreground.BrightYellow)Completed$($psstyle.Reset)"
    Write-Output ""

    ## Display the data on the console
    foreach ($ipAddress in $ipAddresses) {
        Write-Output "[$($psstyle.Foreground.BrightCyan)$ipAddress$($psstyle.Reset)]"
        Write-Output "$($psstyle.Foreground.Green)Lowest Ping  :$($psstyle.Reset) $($mtrTestResults.$ipAddress.LowestPing)"
        Write-Output "$($psstyle.Foreground.Green)Highest Ping :$($psstyle.Reset) $($mtrTestResults.$ipAddress.HighestPing)"
        Write-Output "$($psstyle.Foreground.Green)Average Ping :$($psstyle.Reset) $([math]::Round($mtrTestResults.$ipAddress.AveragePing / ($counter - $mtrTestResults.$ipAddress.PacketLost)))"
        Write-Output "$($psstyle.Foreground.Green)Packets Lost :$($psstyle.Reset) $($mtrTestResults.$ipAddress.PacketsLost)"
        Write-Output ""
    }

    Start-Sleep -Seconds 1
} while ($counter -le ($mtrDuration - 1))

########################
# Display Test Results #
########################
Clear-Host
Write-Output $('-' * $consoleWidth -join '')
Write-Output "     $($psstyle.Foreground.BrightCyan)Network Test Results$($psstyle.Reset)"
Write-Output $('-' * $consoleWidth -join '')
Write-Output ""
Write-Output "$($psstyle.Foreground.Green)Test Duration :$($psstyle.Reset) $($mtrDuration / 60) Minute(s)"
Write-Output ""

foreach ($ipAddress in $ipAddresses) {
    Write-Output "[$($psstyle.Foreground.BrightCyan)$ipAddress$($psstyle.Reset)]"
    Write-Output "$($psstyle.Foreground.Green)Lowest Ping  :$($psstyle.Reset) $($mtrTestResults.$ipAddress.LowestPing)"
    Write-Output "$($psstyle.Foreground.Green)Highest Ping :$($psstyle.Reset) $($mtrTestResults.$ipAddress.HighestPing)"
    Write-Output "$($psstyle.Foreground.Green)Average Ping :$($psstyle.Reset) $([math]::Round($mtrTestResults.$ipAddress.AveragePing / ($mtrDuration - $mtrTestResults.$ipAddress.PacketLost)))"
    Write-Output "$($psstyle.Foreground.Green)Packets Lost :$($psstyle.Reset) $($mtrTestResults.$ipAddress.PacketsLost)"
    Write-Output ""
}

$ipInfo | Format-List

#######################
# Create the log file #
#######################
Add-Content -Path $resultPath -Value "Network Test Log"
Add-Content -Path $resultPath -Value "Test Duration : $($mtrDuration / 60) Minute(s)"
Add-Content -Path $resultPath -Value ""

foreach ($ipAddress in $ipAddresses) {
    Add-Content -Path $resultPath -Value "[$ipAddress]"
    Add-Content -Path $resultPath -Value "Lowest Ping  : $($mtrTestResults.$ipAddress.LowestPing)"
    Add-Content -Path $resultPath -Value "Highest Ping : $($mtrTestResults.$ipAddress.HighestPing)"
    Add-Content -Path $resultPath -Value "Average Ping : $([math]::Round($mtrTestResults.$ipAddress.AveragePing / ($mtrDuration - $mtrTestResults.$ipAddress.PacketLost)))"
    Add-Content -Path $resultPath -Value "Packets Lost : $($mtrTestResults.$ipAddress.PacketsLost)"
    Add-Content -Path $resultPath -Value ""
}

$ipInfo | Out-File -Path $resultPath -Append