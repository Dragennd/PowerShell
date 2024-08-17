# Created by: tim.herndon@bit-wizards.com
# Created on: 8/12/2024
# Last Updated: 8/12/2024

# Colors
# Blue - Data specific to active modes
# Cyan - Headers for menu sections



######################
## Global Variables ##
######################

$Global:TenantOnMicrosoftDomain = "None"
$Global:TenantName = "None"
$Global:CurrentScript = "None"
$Global:ConsoleMaxWidth = [Math]::Max(0, $Host.UI.RawUI.BufferSize.Width)



######################
## Script Functions ##
######################

# Start flow control functions
function Invoke-MainEntryScreen {
    Invoke-Header

    if ($Global:TenantOnMicrosoftDomain -eq "None") {
        Set-ActiveTenant
    }

    Invoke-Menu
}

function Invoke-Header {
    # Specify the title to display to the console
    $Title = "M365 Script Collection"

    # Determine where on the console to display the header text
    $TitleMidPoint = [Math]::Floor($Title.Length / 2)
    $TitlePosition = ($Global:ConsoleMaxWidth / 2) - $TitleMidpoint - 14
    $SecondTitleDivider = $TitlePosition
    
    # Write the header to the console
    Clear-Host
    Write-Host ("{0}" -f ("$([char]0x2500)" * $ConsoleMaxWidth))
    Write-Host ("{0}{1}{2}{3}{4}" -f ("Current Script", (' ' * $TitlePosition), $Title, (' ' * $SecondTitleDivider), "Current Tenant"))
    Write-Host ("{0}{1}{2}" -f ($Global:CurrentScript, (' ' * ($Global:ConsoleMaxWidth - $CurrentScript.Length - $TenantName.Length)), $TenantName)) -ForegroundColor Blue
    Write-Host ("{0}" -f ("$([char]0x2500)" * $Global:ConsoleMaxWidth))
}

function Invoke-Menu {
    Clear-Host

    Invoke-Header
    Write-Host ""

    # Exchange Online scripts
    Write-Host (" {0}{1}{2}{3}{4}" -f ("$([char]0x250C)", ("$([char]0x2500)" * 2), " Exchange Online ", ("$([char]0x2500)" * 30), "$([char]0x2510)")) -ForegroundColor Cyan
    Write-Host "  [1]  Convert User Mailbox to Shared Mailbox"
    Write-Host "  [2]  Manage Mailbox Archive Status"
    Write-Host "  [3]  Manage Message Size Restrictions"
    Write-Host "  [4]  Manage Distribution Lists"
    Write-Host "  [5]  Check Shared Mailbox Permissions"
    Write-Host "  [6]  Check Mailbox Calendar Permissions"
    Write-Host (" {0}{1}{2}" -f ("$([char]0x2514)", ("$([char]0x2500)" * 49), "$([char]0x2518)")) -ForegroundColor Cyan
    Write-Host ""
    
    # 365 Admin scripts
    Write-Host (" {0}{1}{2}{3}{4}" -f ("$([char]0x250C)", ("$([char]0x2500)" * 2), " 365 Administration ", ("$([char]0x2500)" * 27), "$([char]0x2510)")) -ForegroundColor Cyan
    Write-Host "  [7]  Manage Group Membership"
    Write-Host "  [8]  Reset User Passwords"
    Write-Host "  [9]  Duplicate User Permissions to Another User"
    Write-Host "  [10] User Offboarding"
    Write-Host (" {0}{1}{2}" -f ("$([char]0x2514)", ("$([char]0x2500)" * 49), "$([char]0x2518)")) -ForegroundColor Cyan

    Write-Host ""
    Write-Host "  [C]  Change Active Client"
    Write-Host "  [X]  Exit"
    Write-Host ""
    Write-Host ""

    $Selection = Read-Host "Select a script to run"

    if (![string]::IsNullOrWhiteSpace($Selection)) {
        Get-MenuSelection -ScriptSelection $Selection
    }
    else {
        Invoke-Menu
    }
}

function Get-MenuSelection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ScriptSelection
    )

    switch ($ScriptSelection) {
        "1" {Set-MailboxType}
        #"2" {}
        #"3" {}
        #"4" {}
        #"5" {}
        #"6" {}
        #"7" {}
        #"8" {}
        #"9" {}
        #"10" {}
        "C" {Set-ActiveTenant}
        "X" {
            Write-Host "Exiting M365 Script Collection..."
            Start-Sleep 1
            Clear-Host
            Exit
        }
        default {Invoke-Menu}
    }
}

function Set-ActiveTenant {
    # Prompt for client selection from user and then add the values to the global variables
    Clear-Host
    Invoke-Header

    Write-Host ""
    Read-Host "Press [ENTER] to select a client"

    $Global:TenantOnMicrosoftDomain = "advfire.onmicrosoft.com"
    $Global:TenantName = "Advanced Fire Protection Services"

    Invoke-Menu
}
# End flow control functions

# Start script activation functions
function Set-MailboxType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [bool] $ActiveSession
    )
    
    begin {
        if ($ActiveSession -ne $true) {
            if ($Global:TenantOnMicrosoftDomain -ne "None") {
                Connect-ExchangeOnline -DelegatedOrganization $Global:TenantOnMicrosoftDomain
            }
            else {
                Set-ActiveTenant
            }
        }
    }
    
    process {
        do {
            $Global:CurrentScript = "Convert User Mailbox to Shared Mailbox"
            
            Clear-Host
            Invoke-Header

            Write-Host ""
            Read-Host "Press [ENTER] to select a User Mailbox"
            $SelectedUser = Get-EXOMailbox | Select-Object DisplayName,UserPrincipalName,PrimarySMTPAddress,RecipientType,GUID | Out-GridView -OutputMode Single

            Clear-Host
            $Global:CurrentScript = "Convert User Mailbox to Shared Mailbox"
            Invoke-Header

            Write-Host ""
            Write-Host (" {0}{1}{2}{3}{4}" -f ("$([char]0x250C)", ("$([char]0x2500)" * 2), " Selected Client Info ", ("$([char]0x2500)" * 26), "$([char]0x2510)")) -ForegroundColor Cyan
            Write-Host "  Current Client"
            Write-Host "     $Global:TenantName" -ForegroundColor Blue
            Write-Host ""
            Write-Host "  Selected User"
            Write-Host "     $($SelectedUser.DisplayName)" -ForegroundColor Blue
            Write-Host "     $($SelectedUser.PrimarySMTPAddress)" -ForegroundColor Blue
            Write-Host (" {0}{1}{2}" -f ("$([char]0x2514)", ("$([char]0x2500)" * 50), "$([char]0x2518)")) -ForegroundColor Cyan
            Write-Host ""

            $Selection = Read-Host "Is the above selection correct? [Y] or [N]"

            if ($Selection -eq 'N') {
                Write-Host ""
                Write-Host "  [C] Change User"
                Write-Host "  [X] Return to Main Menu"
                Write-Host ""

                do {
                    $NewSelection = Read-Host "Select an option"
    
                    switch ($NewSelection) {
                        "C" {break}
                        "X" {Invoke-Menu}
                    }
                } while ($NewSelection -ne 'C' -and $NewSelection -ne 'X')
            }
        } while ($Selection -ne 'Y')

        Write-Host ""
        Write-Host "Converting Mailbox..."
        Write-Host ""

        Set-Mailbox -Identity $SelectedUser.GUID -Type Shared

        Write-Host ""
    }
    
    end {
        do {
            $EndingPrompt = Read-Host "Convert another mailbox within $($TenantName)? [Y] or [N]"
        } while ($EndingPrompt -ne 'Y' -and $EndingPrompt -ne 'N')

        if ($EndingPrompt -eq 'Y') {
            Set-MailboxType -ActiveSession $true
        }
        else {
            Disconnect-ExchangeOnline -Confirm:$false
            $Global:CurrentScript = "None"
            Invoke-MainEntryScreen
        }
    }
}
# End script activation functions



#################
## Script Flow ##
#################

Invoke-MainEntryScreen