######################
## Global Variables ##
######################

# Fill out these variables and then run the script from the command line

$path = "" # Path the script will search the contents of (i.e "C:\Users")
$logFileDirectory = "C:\path" # Location the log file is saved to
$logFileName = "search-log.log" # Name of the log file
$searchSubFolders = $true # Set to $false if the only folder that needs to be searched is the root folder in $path
$searchCriteria = "" # Follows regex pattern (i.e "Microsoft|Google|- Copy")
$deleteLocatedFilesandFolders = $false # Set to $true if the located files need to be deleted after they have been found



############################################
## Don't Change Anything Below This Point ##
############################################

# Create log file
New-Item -Path $logFileDirectory -Name $logFileName -ItemType File

Function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string] $Message,
        [Parameter(Mandatory = $false)] [ValidateSet("INFO","WARNING","ERROR")] [string] $Level = "INFO"
    )
    $Timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    Add-Content -Path "$($logFileDirectory)\$($logFileName)" -Value "$timestamp [$level] - $message"
}

if ($searchSubFolders -eq $true) {
    $searchContents = Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -match $searchCriteria}

    foreach ($item in $searchContents) {
        Write-Output $item.FullName
        Write-Log -Level INFO -Message $item.FullName

        if ($deleteLocatedFilesandFolders -eq $true) {
            $item | Remove-Item
            Write-Output "$($item.Name) was deleted."
            Write-Log -Level WARNING -Message "$($item.Name) was deleted."
        }
    }
}
else {
    $searchContents = Get-ChildItem $path -ErrorAction SilentlyContinue | Where-Object {$_.Name -match $searchCriteria}

    foreach ($item in $searchContents) {
        Write-Output $item.FullName
        Write-Log -Level INFO -Message $item.FullName

        if ($deleteLocatedFilesandFolders -eq $true) {
            $item | Remove-Item
            Write-Output "$($item.Name) was deleted."
            Write-Log -Level WARNING -Message "$($item.Name) was deleted."
        }
    }
}