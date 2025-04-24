### Purpose ###
# Creates a shortcut on the user's desktop that runs a powershell script

### Note ###
# Any shortcuts created for scripts that require elevated permissions must be ran as admin manually


# Location of the script to make a shortcut of
$ScriptPath = "C:\Temp\<script filename>.ps1"

# Location to create the shortcut at
$ShortcutName = "C:\Temp\<name for the shortcut>.lnk"



### DO NOT MODIFY ANYTHING BELOW THIS LINE ###

$WshShell = New-Object -ComObject WScript.Shell

# Names the shortcut file
$Shortcut = $WshShell.CreateShortcut($ShortcutName)
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

# Arguments that point to the script to run as well as bypass the execution policy on the computer
$Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""$ScriptPath"" -NoExit"
$Shortcut.Save()