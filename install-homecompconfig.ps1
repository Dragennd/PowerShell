# Specify the Log Folder location
$dataFolder = "C:\Temp"

# Set the Log File Location
$logFile = "$dataFolder\SetupLog.log"

# Winget Log Filename Array
$arrayPosition = 0
$appNameArray = @("Windows Terminal",
                  "Visual Studio Code",
                  "PuTTY",
                  "PowerShell",
                  "Google Chrome",
                  "Discord",
                  "Visual Studio Community 2022",
                  "qBittorrent",
                  "7-Zip",
                  "Corsair iCUE5 Software",
                  "Logitech G HUB",
                  "DB Browser for SQLite",
                  "Google Drive",
                  "PotPlayer-64 bit",
                  "GIMP",
                  "Git",
                  "Oh My Posh",
                  "ATLauncher Setup",
                  "WinSCP",
                  "Java(TM) SE Development Kit 17",
                  "Java(TM) SE Development Kit 18",
                  "Java 8",
                  "Wireshark",
                  "Microsoft 365 Apps for enterprise")

$wingetIDs = @("Microsoft.WindowsTerminal",
               "Microsoft.VisualStudioCode",
               "PuTTY.PuTTY",
               "Microsoft.PowerShell",
               "Google.Chrome",
               "Discord.Discord",
               "Microsoft.VisualStudio.2022.Community",
               "qBittorrent.qBittorrent",
               "7zip.7zip",
               "Corsair.iCUE.5",
               "Logitech.GHUB",
               "DBBrowserForSQLite.DBBrowserForSQLite",
               "Google.GoogleDrive",
               "Daum.PotPlayer",
               "GIMP.GIMP",
               "Git.Git",
               "JanDeDobbeleer.OhMyPosh",
               "ATLauncher.ATLauncher",
               "WinSCP.WinSCP",
               "Oracle.JDK.17",
               "Oracle.JDK.18",
               "Oracle.JavaRuntimeEnvironment",
               "WiresharkFoundation.Wireshark",
               "Microsoft.Office")

# Function to add data to the log file
Function Write-Log {
    param(
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $false)] [ValidateSet("INFO","WARNING","ERROR")] [string] $Level = "INFO"
    )
    $Timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
}

# Function to check if the software is currently installed
Function Get-InstallStatus {
    $installStatus = $false
    $wingetQuery = winget list --query $appNameArray[$arrayPosition] --accept-source-agreements

    foreach ($line in $wingetQuery[1..$wingetQuery.Count]) {
        if ($line.Contains($appNameArray[$arrayPosition]) -and $installStatus -eq $false) {
            $installStatus = $true
        }
    }

    if ($installStatus) {
        return $true
    } else {
        return $false
    }
}

# Loop through and install all listed software using winget
do {
    # Check to see if the current software is installed
    if (Get-InstallStatus) {
        Write-Output "Installed $($appNameArray[$arrayPosition])."
        Write-Log -Level INFO -Message "Installed $($appNameArray[$arrayPosition])."
    } else {
        # Check to see if the current software is Windows Terminal
        if ($($wingetIDs[$arrayPosition]) -eq "Microsoft.WindowsTerminal") {
            # Check to see if the XAML package is already installed, if so skip dependencies
            if ((Get-Appxpackage).where({$_.name -match 'Microsoft.UI.Xaml'})) {
                winget.exe install --id "Microsoft.WindowsTerminal" --source winget --silent --skip-dependencies
                if (Get-InstallStatus) {
                    Write-Output "Installed Windows Terminal."
                    Write-Log -Level INFO -Message "Installed Windows Terminal."
                } else {
                    Write-Output "Failed to install Windows Terminal."
                    Write-Log -Level ERROR -Message "Failed to install Windows Terminal."
                }
            } else {
                winget.exe install --id "Microsoft.WindowsTerminal" --source winget --silent
                if (Get-InstallStatus) {
                    Write-Output "Installed Windows Terminal."
                    Write-Log -Level INFO -Message "Installed Windows Terminal."
                } else {
                    Write-Output "Failed to install Windows Terminal."
                    Write-Log -Level ERROR -Message "Failed to install Windows Terminal."
                }
            }
        } else {
            # If the current software is not Windows Terminal, loop through the list like normal
            winget.exe install --id $($wingetIDs[$arrayPosition]) --source winget --silent
            if (Get-InstallStatus) {
                Write-Output "Installed $($appNameArray[$arrayPosition])."
                Write-Log -Level INFO -Message "Installed $($appNameArray[$arrayPosition])."
            } else {
                Write-Output "Failed to install $($appNameArray[$arrayPosition])."
                Write-Log -Level ERROR -Message "Failed to install $($appNameArray[$arrayPosition])."
            }
        }
    }

    $arrayPosition++
} while ($arrayPosition -le 25)