# this script is greatly inspired by https://gist.github.com/Luzefiru/19c0759bea1b9e7ef480bb39303b3f6c
Add-Type -AssemblyName System.Web

$64 = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
$32 = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
Write-Output "Attempting to find URL automatically..."

# Native
try {
    $gamePath = (Get-ItemProperty -Path $32, $64 | Where-Object { $_.DisplayName -like "*wuthering*" } | Select-Object InstallPath).PSObject.Properties.Value
    if ((Test-Path ($gamePath + '\Client\Saved\Logs\Client.log') -or Test-Path($gamePath + '\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\KRSDKRes\KRSDKWebView\debug.log'))) {
        $gachaLogPathExists = $true
    }
}
catch {
    $gamePath = $null
    $gachaLogPathExists = $false
}

# MUI Cache
if (!$gachaLogPathExists) {
    $muiCachePath = "Registry::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
    $filteredEntries = (Get-ItemProperty -Path $muiCachePath).PSObject.Properties | Where-Object { $_.Value -like "*wuthering*" } | Where-Object { $_.Name -like "*client-win64-shipping.exe*" }
    if ($filteredEntries.Count -ne 0) {
        $gamePath = ($filteredEntries[0].Name -split '\\client\\')[0]
        if ((Test-Path ($gamePath + '\Client\Saved\Logs\Client.log')) -or (Test-Path ($gamePath + '\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\KRSDKRes\KRSDKWebView\debug.log'))) {
            $gachaLogPathExists = $true
        }
    }
}

# Firewall 
if (!$gachaLogPathExists) {
    $firewallPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
    $filteredEntries = (Get-ItemProperty -Path $firewallPath).PSObject.Properties | Where-Object { $_.Value -like "*wuthering*" } | Where-Object { $_.Name -like "*client-win64-shipping*" }
    if ($filteredEntries.Count -ne 0) {
        $gamePath = (($filteredEntries[0].Value -split 'App=')[1] -split '\\client\\')[0]
        if ((Test-Path ($gamePath + '\Client\Saved\Logs\Client.log')) -or (Test-Path ($gamePath + '\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\KRSDKRes\KRSDKWebView\debug.log'))) {
            $gachaLogPathExists = $true
        }
    }
}

# Common Installation Paths
if (!$gachaLogPathExists) {
    $diskLetters = (Get-PSDrive).Name -match '^[a-z]$'
    foreach ($diskLetter in $diskLetters) {
        $gamePaths = @(
            "$diskLetter`:\Wuthering Waves Game",
            "$diskLetter`:\Wuthering Waves\Wuthering Waves Game",
            "$diskLetter`:\Program Files\Epic Games\WutheringWavesj3oFh\Wuthering Waves Game"
        )
    
        foreach ($gamePath in $gamePaths) {
            if ((Test-Path ($gamePath + '\Client\Saved\Logs\Client.log')) -or (Test-Path ($gamePath + '\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\KRSDKRes\KRSDKWebView\debug.log')) ) {
                $gamePath = $gamePath
                $gachaLogPathExists = $true
                break
            }
        }
    
        if ($gachaLogPathExists -or $gamePath) {
            break
        }
    }
}

# Manual
while (!$gachaLogPathExists) {
    Write-Host "Game install location not found or log files missing. If you think that your installation directory is correct and it's still not working, please make issue on https://github.com/Anubhav1603/Wuthering-Waves-Convene-URL-Extractor. Otherwise, please enter the game install location path."
    Write-Host 'Common install locations:'
    Write-Host '  C:\Wuthering Waves' -ForegroundColor Yellow
    Write-Host '  C:\Wuthering Waves\Wuthering Waves Game' -ForegroundColor Yellow
    Write-Host '  C:\Program Files\Epic Games\WutheringWavesj3oFh' -ForegroundColor Yellow
    $path = Read-Host "Path"
    if ($path) {
        $gamePath = $path
        if ((Test-Path ($gamePath + '\Client\Saved\Logs\Client.log')) -or (Test-Path ($gamePath + '\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\KRSDKRes\KRSDKWebView\debug.log'))) {
            $gachaLogPathExists = $true
        }
        else {
            Write-Host "Could not find log files. Did you set your game location properly or open your Convene History first?" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Invalid game location. Did you set your game location properly?" -ForegroundColor Red
    }
}

$gachaLogPath = $gamePath + '\Client\Saved\Logs\Client.log'
$debugLogPath = $gamePath + '\Client\Binaries\Win64\ThirdParty\KrPcSdk_Global\KRSDKRes\KRSDKWebView\debug.log'

if (Test-Path $gachaLogPath) {
    $gachaUrlEntry = Get-Content $gachaLogPath | Select-String -Pattern "https://aki-gm-resources-oversea\.aki-game\.(net|com)" | Select-Object -Last 1
}
else {
    $gachaUrlEntry = $null
}

if (Test-Path $debugLogPath) {
    $debugUrlEntry = Get-Content $debugLogPath | Select-String -Pattern '"#url": "(https://aki-gm-resources-oversea\.aki-game\.(net|com)[^"]*)"' | Select-Object -Last 1
    $debugUrl = $debugUrlEntry.Matches.Groups[1].Value
}
else {
    $debugUrl = $null
}

if ($gachaUrlEntry -or $debugUrl) {
    if ($gachaUrlEntry) {
        $urlToCopy = $gachaUrlEntry -replace '.*?(https://aki-gm-resources-oversea\.aki-game\.(net|com)[^"]*).*', '$1'
    }
    if ([string]::IsNullOrWhiteSpace($urlToCopy)) {
        $urlToCopy = $debugUrl
    }

    if ([string]::IsNullOrWhiteSpace($urlToCopy)) {
        Write-Host "Cannot find the convene history URL in both Client.log and debug.log! Please open your Convene History first!" -ForegroundColor Red
    }
    else {
        # Prompt user for choice
        Write-Host "Do you want to copy JSON data? (Y/N)" -ForegroundColor Yellow
        $choice = Read-Host
        if ($choice -eq "Y" -or $choice -eq "y") {
            # Define the base URL
            $baseUrl = "https://aki-gm-resources-oversea.aki-game.net/aki/gacha/index.html#/record?"
 
            # Parse URL into key-value pairs
            $urlParams = @{
                "svr_id"       = [regex]::Match($urlToCopy, 'svr_id=([^&]+)').Groups[1].Value
                "player_id"    = [regex]::Match($urlToCopy, 'player_id=([^&]+)').Groups[1].Value
                "lang"         = [regex]::Match($urlToCopy, 'lang=([^&]+)').Groups[1].Value
                "gacha_id"     = [regex]::Match($urlToCopy, 'gacha_id=([^&]+)').Groups[1].Value
                "gacha_type"   = [regex]::Match($urlToCopy, 'gacha_type=([^&]+)').Groups[1].Value
                "svr_area"     = [regex]::Match($urlToCopy, 'svr_area=([^&]+)').Groups[1].Value
                "record_id"    = [regex]::Match($urlToCopy, 'record_id=([^&]+)').Groups[1].Value
                "resources_id" = [regex]::Match($urlToCopy, 'resources_id=([^&]+)').Groups[1].Value
            }
 
            # Add base_url to urlParams
            $urlParams.Add("base_url", $baseUrl)
 
            # Convert to JSON format
            $jsonOutput = ConvertTo-Json -InputObject $urlParams -Depth 5
            
            Write-Host ""
            Write-Host "Json Data" -ForegroundColor Yellow
            Write-Host $jsonOutput -ForegroundColor Yellow

            # Copy JSON to clipboard
            Set-Clipboard $jsonOutput
 
            Write-Host ""
            Write-Host "JSON data has been copied to clipboard. Please paste it in the tracker." -ForegroundColor Green
        }
        else {
            # Copy URL to clipboard for any other choice including "N"
            Set-Clipboard $urlToCopy
 
            Write-Host ""
            Write-Host "Convene Url: $urlToCopy" -ForegroundColor Yellow

            Write-Host ""
            Write-Host "URL has been copied to clipboard. Please paste it in the tracker." -ForegroundColor Green
        }
    }
}
else {
    Write-Host "Cannot find the convene history URL in both Client.log and debug.log! Please open your Convene History first!" -ForegroundColor Red
}