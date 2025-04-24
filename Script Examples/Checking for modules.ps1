# If the module doesn't exist, install the module
if (!(Get-Module -Name ExchangeOnlineManagement)) {
    Install-Module ExchangeOnlineManagement
}