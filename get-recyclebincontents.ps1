$searchBase = "<AD Organizational Unit FQDN>"

$adCompList = Get-ADComputer -Filter * -SearchBase $searchBase

foreach ($comp in $adCompList) {
    Invoke-Command -ComputerName $comp.Name -ScriptBlock {(New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() |`
        Select-Object @{n="OriginalLocation";e={$_.ExtendedProperty("{9B174B33-40FF-11D2-A27E-00C04FC30871} 2")}},Name |`
        Export-Csv -path "C:\path\<filename>.csv" -NoTypeInformation}
}