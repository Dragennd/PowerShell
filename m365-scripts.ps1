# Created by: tim.herndon@bit-wizards.com
# Created on: 8/12/2024
# Last Updated: 8/12/2024



######################
## Script Functions ##
######################

function WriteHeader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $CurrentScript
    )

    $title = "M365 Script Collection"

    $consoleMaxWidth = [Math]::Max(0, $Host.UI.RawUI.BufferSize.Width)
    $titleMidPoint = [Math]::Floor($title.Length / 2)
    $titlePosition = ($consoleMaxWidth / 2) - $titleMidpoint - 16
    
    # Write the header to the console
    Clear-Host
    Write-Host ("{0}" -f ('-' * $consoleMaxWidth))
    Write-Host "Current Script: " -NoNewline
    Write-Host ("{0}{1}" -f ((' ' * $titlePosition), $title))
    Write-Host "$currentScript" -ForegroundColor Blue
    Write-Host ("{0}" -f ('-' * $consoleMaxWidth))
}

function WriteMenu {
    Write-Host ""
    Write-Host "Exchange Online"
    Write-Host "[1] Convert User Mailbox to Shared Mailbox"
    Write-Host "[2] Manage Mailbox Archive Status"
    Write-Host "[3] Manage Message Size Restrictions"
    Write-Host "[4] Manage Distribution Lists"
    Write-Host "[5] Check Shared Mailbox Permissions"
    Write-Host "[6] Check Mailbox Calendar Permissions"
    Write-Host ""
    
    Write-Host "365 Administration"
    Write-Host "[7] Manage Group Membership"
    Write-Host "[8] Reset User Passwords"
    Write-Host "[9] Duplicate Permissions from User to User"
    Write-Host "[10] User Offboarding"
    Write-Host ""
}

function ConvertMailboxToSharedMailbox {
    WriteHeader -CurrentScript "Convert User Mailbox to Shared Mailbox"
    Write-Host ""
    Read-Host ":"
}

function ProcessMenuSelection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [int] $ScriptSelection
    )

    switch ($scriptSelection) {
        1 {ConvertMailboxToSharedMailbox}
        2 {}
        3 {}
        4 {}
        5 {}
        6 {}
        7 {}
        8 {}
        9 {}
        10 {}
    }

}



#################
## Script Flow ##
#################

WriteHeader -CurrentScript "None"
$selection = Read-Host "Select a script to run"
ProcessMenuSelection -ScriptSelection $selection