# Destination for the downloaded file, including filename
$AppInstallPath = "C:\Temp\MITS Network Monitor.exe"

# URL to the file to be downloaded
$FullUri = '<URL to item to download>'

# Download the file and send it to the specified path
(New-Object System.Net.WebClient).DownloadFile($FullUri, $AppInstallPath)