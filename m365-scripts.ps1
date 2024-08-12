# Created by: tim.herndon@bit-wizards.com
# Created on: 8/12/2024
# Last Updated: 8/12/2024

$title = "M365 Script Collection"
$consoleMaxWidth = [Math]::Max(0, $Host.UI.RawUI.BufferSize.Width)
$titleMidPoint = [Math]::Floor($title.Length / 2)
$titlePosition = ($consoleMaxWidth / 2) - $titleMidpoint

# Write the header to the console
Clear-Host
Write-Host ("{0}" -f ('-' * $consoleMaxWidth))
Write-Host ("{0}{1}" -f ((' ' * $titlePosition), $title))
Write-Host ("{0}" -f ('-' * $consoleMaxWidth))

Write-Host ""
Write-Host "Exchange Scripts"
Write-Host "[1] Convert Mailbox to Shared Mailbox"
Write-Host "[2] Manage Mailbox Archive Status"
Write-Host "[3] Manage Message Size Restrictions"
Write-Host "[4] Manage Distribution Lists"
Write-Host "[5] Check Shared Mailbox Permissions"
Write-Host "[6] Check Mailbox Calendar Permissions"
Write-Host ""

$scriptSelection = Read-Host "Select a script to run"