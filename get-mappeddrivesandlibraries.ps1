$Data = @()
$ProfileDirectory = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"
$Sids = @(Get-WmiObject win32_userprofile | Select-Object -ExpandProperty SID)

foreach ($Sid in $Sids) {
    $SelectedProfile = Get-ChildItem -Path $ProfileDirectory -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "$($Sid)" }
    $SelectedProfileProperties = Get-ItemProperty -Path "registry::$($SelectedProfile)" -ErrorAction SilentlyContinue
    $Libraries = Get-ChildItem -Path "registry::HKEY_USERS\$Sid\Software\SyncEngines\Providers\OneDrive" -ErrorAction SilentlyContinue
    $Drives = Get-ChildItem -Path "registry::HKEY_USERS\$Sid\Network" -ErrorAction SilentlyContinue

    foreach ($Library in $Libraries) {
        $URLNamespace = Get-ItemProperty "registry::HKEY_USERS\$Sid\Software\SyncEngines\Providers\OneDrive\$($Library.PSChildName)" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty UrlNamespace
        if ($URLNamespace -notlike "*personal*") {
            $Data += [PSCustomObject]@{
                "User Account"       = ($SelectedProfileProperties.ProfileImagePath).Split('\')[2]
                "Path"               = $URLNamespace
                "Type"               = "SharePoint Library"
                "Letter"             = ""
            }
        }
    }

    foreach ($Drive in $Drives) {
        $DrivePath = Get-ItemProperty "registry::HKEY_USERS\$Sid\Network\$($Drive.PSChildName)" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty RemotePath
        $Data += [PSCustomObject]@{
            "User Account"       = ($SelectedProfileProperties.ProfileImagePath).Split('\')[2]
            "Path"               = $DrivePath
            "Type"               = "Mapped Drive"
            "Letter"             = $Drive.PSChildName
        }
    }
}

$Data