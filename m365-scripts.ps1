# Created by: tim.herndon@bit-wizards.com
# Created on: 8/12/2024
# Last Updated: 8/12/2024

# Colors
# Blue - Data specific to active modes
# Cyan - Headers for menu sections



######################
## Script Functions ##
######################

# Start flow control functions
function WriteMainEntryScreenToConsole {
    WriteHeaderToConsole -CurrentScript "None"
    WriteMenuToConsole
}

function WriteHeaderToConsole {
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
    Write-Host $currentScript -ForegroundColor Blue
    Write-Host ("{0}" -f ('-' * $consoleMaxWidth))
}

function WriteMenuToConsole {
    Write-Host ""

    # Exchange Online scripts
    Write-Host "-- Exchange Online --" -ForegroundColor Cyan
    Write-Host "[1] Convert User Mailbox to Shared Mailbox"
    Write-Host "[2] Manage Mailbox Archive Status"
    Write-Host "[3] Manage Message Size Restrictions"
    Write-Host "[4] Manage Distribution Lists"
    Write-Host "[5] Check Shared Mailbox Permissions"
    Write-Host "[6] Check Mailbox Calendar Permissions"
    Write-Host ""
    
    # 365 Admin scripts
    Write-Host "-- 365 Administration --" -ForegroundColor Cyan
    Write-Host "[7] Manage Group Membership"
    Write-Host "[8] Reset User Passwords"
    Write-Host "[9] Duplicate User Permissions to Another User"
    Write-Host "[10] User Offboarding"
    Write-Host ""

    Write-Host "[X] Exit"
    Write-Host ""

    $selection = Read-Host "Select a script to run"
    ProcessMenuSelection -ScriptSelection $selection
}

function ProcessMenuSelection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ScriptSelection
    )

    switch ($scriptSelection) {
        "1" {ConvertUserMailboxToSharedMailbox -OnMicrosoftDomain "advfire.onmicrosoft.com" -ClientName "Advanced Fire Protection Services"}
        "2" {}
        "3" {}
        "4" {}
        "5" {}
        "6" {}
        "7" {}
        "8" {}
        "9" {}
        "10" {}
        default {Read-Host "Press any key to exit..."}
    }
}
# End flow control functions

# Start script activation functions
function ConvertUserMailboxToSharedMailbox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $OnMicrosoftDomain,
        [Parameter(Mandatory=$true)]
        [string] $ClientName,
        [Parameter(Mandatory=$false)]
        [bool] $ActiveSession
    )
    
    begin {
        if ($ActiveSession -ne $true) {
            Connect-ExchangeOnline -DelegatedOrganization $OnMicrosoftDomain
        }
    }
    
    process {
        do {
            WriteHeaderToConsole -CurrentScript "Convert User Mailbox to Shared Mailbox"
            Write-Host ""
            Write-Host "Active Client: " -NoNewline
            Write-Host $ClientName -ForegroundColor Blue
            Write-Host ""

            Read-Host "Press [ENTER] to select a User Mailbox"
            $user = Get-EXOMailbox | Select-Object DisplayName,UserPrincipalName,PrimarySMTPAddress,RecipientType,GUID | Out-GridView -OutputMode Single

            Clear-Host
            WriteHeaderToConsole -CurrentScript "Convert User Mailbox to Shared Mailbox"
            Write-Host ""
            Write-Host "Active Client: " -NoNewline
            Write-Host $ClientName -ForegroundColor Blue
            Write-Host "Selected User: " -NoNewline
            Write-Host $user.DisplayName -ForegroundColor Blue
            Write-Host ""

            $selection = Read-Host "Is the above selection correct? [Y] or [N]"
        } while ($selection -ne 'Y')

        Write-Host "Converting Mailbox..."
        Write-Host ""
        # Run cmdlet to convert the mailbox from user to shared
        # Add error handling - if mailbox conversion fails, display error - otherwise display success message
        Write-Host ""
    }
    
    end {
        do {
            $endingPrompt = Read-Host "Convert another mailbox within $($ClientName)? [Y] or [N]"
        } while ($endingPrompt -ne 'Y' -and $endingPrompt -ne 'N')

        if ($endingPrompt -eq 'Y') {
            ConvertUserMailboxToSharedMailbox -OnMicrosoftDomain $OnMicrosoftDomain -ClientName $ClientName -ActiveSession $true
        }
        else {
            Disconnect-ExchangeOnline -Confirm:$false
            WriteMainEntryScreenToConsole
        }
    }
}
# End script activation functions



#################
## Script Flow ##
#################

WriteMainEntryScreenToConsole