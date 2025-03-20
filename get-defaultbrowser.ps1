$Data = @()
$ProfileDirectory = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"
$Sids = @(Get-WmiObject win32_userprofile | Select-Object -ExpandProperty SID)

foreach ($Sid in $Sids) {
    $SelectedProfile = Get-ChildItem -Path $ProfileDirectory -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "$($Sid)" }
    $SelectedProfileProperties = Get-ItemProperty -Path "registry::$($SelectedProfile)" -ErrorAction SilentlyContinue
    $Browser = Get-ItemProperty "registry::HKEY_USERS\$Sid\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProgId

    Switch ($Browser) {
        'ChromeHTML' { $DefaultBrowser = "Google Chrome" }
        'IE.HTTP' { $DefaultBrowser = "Internet Explorer" }
        'FirefoxURL-308046B0AF4A39CB' { $DefaultBrowser = "Mozilla FireFox" }
        'AppXq0fevzme2pys62n3e0fbqa7peapykr8v' { $DefaultBrowser = "Microsoft Edge" }
    }

    if ([string]::IsNullOrWhiteSpace($DefaultBrowser)) {
        $DefaultBrowser = "Microsoft Edge"
    }

    $Data += [PSCustomObject]@{
        "User Account"    = ($SelectedProfileProperties.ProfileImagePath).Split('\')[2]
        "Default Browser" = $DefaultBrowser
    }
}

$Data