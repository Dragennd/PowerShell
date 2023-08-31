####################################
## User Profile Removal Script
## Last Updated: 8/4/2023
####################################


$scriptLocation = "C:\BWIT"
$scriptToCreate = {
$date = Get-Date -Format "MM-dd-yy"

# Function for removing the user profile registry key and
# renaming the user folder to <name>.<current date>
function remove-userprofile {
    $regPath = $profileItems.Keys | Where-Object { $profileItems[$_] -eq $lbProfiles.SelectedItem }
    $profileImagePath = Get-ItemProperty "Registry::$regPath" | Select-Object ProfileImagePath

    takeown.exe -a -f $profileImagePath.ProfileImagePath
    Remove-Item -Path "Registry::$regPath" -Recurse
    Rename-Item -Path $profileImagePath.ProfileImagePath -NewName "$(($profileImagePath.ProfileImagePath).Split("\")[2]).$date"
}

# Generate WPF Form
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:DeleteUserProfile"
        Title="Local Profile Remover" Height="470" Width="265">
    <Grid>
        <Canvas>
            <ListBox Name="lbProfiles" Height="355" Width="230" Canvas.Left="10" Canvas.Top="10" HorizontalAlignment="Center" VerticalAlignment="Top" BorderBrush="Black"/>
            <Button Name="btnDelete" Content="Remove Selected Profile" Canvas.Left="55" Canvas.Top="388" HorizontalAlignment="Left" VerticalAlignment="Top" Width="140" Height="25"/>
        </Canvas>
    </Grid>
</Window>
"@

# Process the XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form = [Windows.Markup.XamlReader]::Load($reader)}
catch{Write-Host "Unable to load Windows.Markup.XamlReader"; exit}

# Generate variables for each WPF form object
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

# Generate List of Users
$profileDirectory = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$profileObjects = Get-ChildItem -Path $profileDirectory

$profileItems = @{}

foreach ($profileObject in $profileObjects) {
    $imagePath = Get-ItemProperty -Path "Registry::$($profileObject.Name)" | Select-Object ProfileImagePath
    $truncatedPath = ($imagePath.ProfileImagePath).Split("\")
    if ($truncatedPath[1] -eq "Users") {
        $profileItems.Add($profileObject.Name, $truncatedPath[2])
    }
}

# Add usernames to the listbox
$profileItems.Values | ForEach-Object {$lbProfiles.Items.Add($_)}

# Apply the function to button
$btnDelete.Add_Click({
    remove-userprofile
})

# Show the WPF Form
$Form.ShowDialog() | out-null
}

# Check to see if the BWIT directory exists
# and if not, create it, then create the script file
if (Test-Path $scriptLocation) {
    $scriptToCreate | Out-File "$scriptLocation\remove-userprofile.ps1" -Width 300
} else {
    New-Item -ItemType "Directory" -Name "BWIT" -Path "C:\"
    $scriptToCreate | Out-File "$scriptLocation\remove-userprofile.ps1" -Width 300
}

# Launch the newly created script file as administrator
Start-Process powershell -ArgumentList "-File $scriptLocation\remove-userprofile.ps1" -Verb RunAs