# Created by: tim.herndon@bit-wizards.com
# Created on: 8/12/2024
# Last Updated: 8/22/2024

# Colors
# Blue - Data specific to active modes
# Cyan - Headers for menu sections



########################################################
## Global Variables ####################################
########################################################

$Global:TenantOnMicrosoftDomain = "None"
$Global:TenantName = "None"
$Global:CurrentScript = "None"
$Global:ConsoleMaxWidth = [Math]::Max(0, $Host.UI.RawUI.BufferSize.Width)



########################################################
## Start flow control functions ########################
########################################################

########################################################
## v- Start of Main Entry Screen -------------------v ##

function Invoke-MainEntryScreen {
    Invoke-Header

    if ($Global:TenantOnMicrosoftDomain -eq "None") {
        Set-ActiveTenant
    }

    Invoke-Menu
}

## ^- End of Main Entry Screen ---------------------^ ##
##                                                    ##
## v- Start of Header ------------------------------v ##

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

## ^- End of Header --------------------------------^ ##
##                                                    ##
## v- Start of Menu --------------------------------v ##

function Invoke-Menu {
    Clear-Host

    Invoke-Header
    Write-Host ""

    # Exchange Online scripts
    Write-Host (" {0}{1}{2}{3}{4}" -f ("$([char]0x250C)", ("$([char]0x2500)" * 2), " Exchange Online ", ("$([char]0x2500)" * 30), "$([char]0x2510)")) -ForegroundColor Cyan
    Write-Host "  [1]  Convert User Mailbox to Shared Mailbox"
    Write-Host "  [2]  Manage Mailbox Archive"
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
    Write-Host "  [C]  Change Active Tenant"
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

## ^- End of Menu ----------------------------------^ ##
##                                                    ##
## v- Start of Menu Selection ----------------------v ##

function Get-MenuSelection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ScriptSelection
    )

    switch ($ScriptSelection) {
        "1" {Set-MailboxType}
        "2" {Get-MailboxArchiveStatus}
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

## ^- End of Menu Selection ------------------------^ ##
##                                                    ##
## v- Start of Active Tenant -----------------------v ##

function Set-ActiveTenant {
    # Prompt for client selection from user and then add the values to the global variables
    Clear-Host
    Invoke-Header

    Write-Host ""
    Read-Host "Press [ENTER] to select a Tenant"

    $Global:TenantOnMicrosoftDomain = "advfire.onmicrosoft.com"
    $Global:TenantName = "Advanced Fire Protection Services"

    Invoke-Menu
}

## ^- End of Active Tenant -------------------------^ ##
##                                                    ##
## v- Start of Selected User Info ------------------v ##

function Show-SelectedUserInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [object] $SelectedUser
    )

    $UserDataLengths = @($Global:TenantName.Length, $SelectedUser.DisplayName.Length, $SelectedUser.PrimarySMTPAddress.Length)
    $LongestString = 0
    $TopBarLength = 2
    $BottomBarLength = 26

    foreach ($Count in $UserDataLengths) {
        if ($Count -gt $LongestString) {
            $LongestString = $Count
        }
    }

    if ($LongestString -ge 26) {
        $TopBarLength = $LongestString - 20
        $BottomBarLength = $LongestString + 4
    }

    Write-Host ""
    Write-Host (" {0}{1}{2}{3}{4}" -f ("$([char]0x250C)", ("$([char]0x2500)" * 2), " Selected Client Info ", ("$([char]0x2500)" * $TopBarLength), "$([char]0x2510)")) -ForegroundColor Cyan
    Write-Host "  Selected Tenant"
    Write-Host "     $Global:TenantName" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  Selected User"
    Write-Host "     $($SelectedUser.DisplayName)" -ForegroundColor Blue
    Write-Host "     $($SelectedUser.PrimarySMTPAddress)" -ForegroundColor Blue
    Write-Host (" {0}{1}{2}" -f ("$([char]0x2514)", ("$([char]0x2500)" * $BottomBarLength), "$([char]0x2518)")) -ForegroundColor Cyan
    Write-Host ""
}

## ^- End of Selected User Info --------------------^ ##
########################################################

########################################################
## End flow control functions ##########################
########################################################



########################################################
## Start primary functionality scripts #################
########################################################

########################################################
## v- Start of Set Mailbox Type --------------------v ##

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
            Invoke-Header

            # Display the currently selected user and related info
            Show-SelectedUserInfo -SelectedUser $SelectedUser

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

        Set-Mailbox -Identity $SelectedUser.GUID -Type Shared -WhatIf

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

## ^- End of Set Mailbox Type ----------------------^ ##
##                                                    ##
## v- Start of Get Mailbox Archive Status ----------v ##

function Get-MailboxArchiveStatus {
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
        $Global:CurrentScript = "Manage Mailbox Archive"
            
        Clear-Host
        Invoke-Header

        Write-Host ""
        Read-Host "Press [ENTER] to select a User Mailbox"
        $User = Get-EXOMailbox -Property All | Select-Object DisplayName,PrimarySMTPAddress,RecipientType,GUID,ProhibitSendQuota,ArchiveQuota | Out-GridView -OutputMode Single -Title "Select User"
        $SelectedUser = Get-EXOMailbox -Identity $User.PrimarySMTPAddress -Property All

        Clear-Host
        Invoke-Header

        # Mailbox Usage Info
        $MailboxStatistics = $SelectedUser | Get-EXOMailboxStatistics
        $MailboxTotalBytes = ($MailboxStatistics.TotalItemSize.Value -split ' ')[2].Trim('(') -replace ',', ''
        $MailboxMaxBytes = ($SelectedUser.ProhibitSendQuota -split ' ')[2].Trim('(') -replace ',', ''
        $MailboxUsage = [Math]::Round(($MailboxTotalBytes / $MailboxMaxBytes) * 100, 2)
        $MailboxTitle = " Mailbox Usage [$($MailboxUsage)%] "
        $TopBarLength = 50 - 2 - $MailboxTitle.Length
        $Count = $MailboxUsage
        $MailboxPercentageBar = " "

        while ($Count -gt 0) {
            $MailboxPercentageBar += "$([char]0x2503)"
            $Count -= 2
        }

        # Archive Usage Info
        if ($SelectedUser.ArchiveStatus -eq "Active") {
            $ArchiveStatistics = $SelectedUser | Get-EXOMailboxStatistics -Archive
            $ArchiveTotalBytes = ($ArchiveStatistics.TotalItemSize.Value -split ' ')[2].Trim('(') -replace ',', ''
            $ArchiveMaxBytes = ($SelectedUser.ProhibitSendQuota -split ' ')[2].Trim('(') -replace ',', ''
            $ArchiveUsage = [Math]::Round(($ArchiveTotalBytes / $ArchiveMaxBytes) * 100, 2)
            $Count = $ArchiveUsage
            $ArchivePercentageBar = " "

            while ($Count -gt 0) {
                $ArchivePercentageBar += "$([char]0x2503)"
                $Count -= 2
            }
        } else {
            $ArchiveUsage = "0.0"
            $ArchivePercentageBar = " Disabled"
        }

        $ArchiveTitle = " Archive Usage [$($ArchiveUsage)%] "
        $TopBarLength = 50 - 2 - $ArchiveTitle.Length
        
        # Display the currently selected user and related info
        Write-Host ""
        Write-Host (" {0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}" -f ("$([char]0x250C)", ("$([char]0x2500)" * 2), " Selected Client Info ", ("$([char]0x2500)" * 32), "$([char]0x2510)", (" " * 6), "$([char]0x250C)", ("$([char]0x2500)" * 2), $MailboxTitle, ("$([char]0x2500)" * $TopBarLength), "$([char]0x2510)")) -ForegroundColor Cyan
        Write-Host ("  {0}{1}{2}" -f ("Selected Tenant", (" " * 48), $MailboxPercentageBar))
        Write-Host "     $Global:TenantName" -ForegroundColor Blue -NoNewline
        Write-Host (" {0}{1}{2}{3}" -f ((" " * (63 - ($Global:TenantName.Length + 4))), "$([char]0x2514)", ("$([char]0x2500)" * 50), "$([char]0x2518)")) -ForegroundColor Cyan
        Write-Host (" {0}{1}{2}{3}{4}{5}" -f ((" " * 64), "$([char]0x250C)", ("$([char]0x2500)" * 2), $ArchiveTitle, ("$([char]0x2500)" * $TopBarLength), "$([char]0x2510)")) -ForegroundColor Cyan
        Write-Host ("  {0}{1}{2}" -f ("Selected User", (" " * 50), $ArchivePercentageBar))
        Write-Host "     $($SelectedUser.DisplayName)" -ForegroundColor Blue -NoNewline
        Write-Host (" {0}{1}{2}{3}" -f ((" " * (63 - $($SelectedUser.DisplayName.Length + 4))), "$([char]0x2514)", ("$([char]0x2500)" * 50), "$([char]0x2518)")) -ForegroundColor Cyan
        Write-Host "     $($SelectedUser.PrimarySMTPAddress)" -ForegroundColor Blue
        Write-Host (" {0}{1}{2}" -f ("$([char]0x2514)", ("$([char]0x2500)" * 56), "$([char]0x2518)")) -ForegroundColor Cyan
        Write-Host ""

        Write-Host ""
        Write-Host "  [1] Enable/Disable Mailbox Archive"
        Write-Host "  [2] Enable Auto-Expanding Archive"
        Write-Host "  [3] Run Managed Folder Assistant"
        Write-Host ""
        Write-Host "  [C] Change User"
        Write-Host "  [X] Return to Main Menu"
        Write-Host ""

        do {
            $Selection = Read-Host "Select a task to perform with the selected user account"
        } while ($Selection -ne 'C' -and $Selection -ne 'X' -and $Selection -ne '1' -and $Selection -ne '2' -and $Selection -ne '3')

        switch ($Selection) {
            # to-do:
            # Make individual functions for each of these 3 options and then make a new parameter for the main function to be able to
            # recursively call the function again while reusing the current selections (unless option C is chosen)
            "1" {}
            "2" {}
            "3" {}
            "C" {Get-MailboxArchiveStatus -ActiveSession $true}
            "X" {continue}
        }
    }

    end {
        Disconnect-ExchangeOnline -Confirm:$false
        $Global:CurrentScript = "None"
        Invoke-MainEntryScreen
    }
}

## ^- End of Get Mailbox Archive Status-------------^ ##
########################################################

########################################################
## End primary functionality scripts####################
########################################################



########################################################
## Script Flow #########################################
########################################################

Invoke-MainEntryScreen