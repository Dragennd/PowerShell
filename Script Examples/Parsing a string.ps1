$info = ""
$result = qwinsta

foreach ($line in $result[1..$result.Count]) {
    $info = $line.Split(" ") | Where-Object { $_.length -gt 0 }
    if ($info[1] -eq "drage") {
        $seshID = $info[2]
    }
}

Write-Output $seshID





$wingetQuery = winget list --query mozilla.firefox
$statusCheck = $true

foreach ($line in $wingetQuery[1..$wingetQuery.Count]) {
    if ($line -eq "No installed package found matching input criteria." -and $statusCheck -eq $true) {
        $statusCheck = $false
    }
}


"No installed package found matching input criteria."