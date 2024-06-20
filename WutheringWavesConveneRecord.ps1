# got inspiration from https://gist.github.com/Luzefiru/19c0759bea1b9e7ef480bb39303b3f6c

# Check if the process 'Wuthering Waves.exe' is running
if (($process = Get-WmiObject Win32_Process -Filter "Name='Wuthering Waves.exe'" -ErrorAction SilentlyContinue)) {
    
    # Check if the executable path of the process is available
    if ($process.ExecutablePath) {
        
        # Get the game installation path
        $gamePath = Join-Path (Split-Path $process.ExecutablePath) "Client"
        $gamePath = $gamePath -replace "\\Wuthering Waves.exe$", ""

        # Define the log file path
        $logFile = Join-Path $gamePath "Saved\Logs\Client.log"

        # Check if the log file exists
        if (-not (Test-Path $logFile)) {
            Write-Host ""
            Write-Host "The file '$logFile' does not exist." -ForegroundColor Red
            Write-Host "Did you set your Game Installation Path properly?" -ForegroundColor Magenta
            Read-Host "Press Enter to exit"
            exit
        }


        # Get the latest URL entry from the log file
        $latestUrlEntry = Get-Content $logFile | Select-String "https://aki-gm-resources-oversea.aki-game.net" | Select-Object -Last 1

        # Check if a matching URL entry is found
        if ($latestUrlEntry) {
            $urlPattern = 'url":"(.*?)"'
            $url = [regex]::Match($latestUrlEntry, $urlPattern).Groups[1].Value

            # Check if the URL is extracted successfully
            if ($url) {

                # Define the base URL
                $baseUrl = "https://aki-gm-resources-oversea.aki-game.net/aki/gacha/index.html#/record?"

                # Parse URL into key-value pairs
                $urlParams = @{
                    "svr_id"       = [regex]::Match($url, 'svr_id=([^&]+)').Groups[1].Value
                    "player_id"    = [regex]::Match($url, 'player_id=([^&]+)').Groups[1].Value
                    "lang"         = [regex]::Match($url, 'lang=([^&]+)').Groups[1].Value
                    "gacha_id"     = [regex]::Match($url, 'gacha_id=([^&]+)').Groups[1].Value
                    "gacha_type"   = [regex]::Match($url, 'gacha_type=([^&]+)').Groups[1].Value
                    "svr_area"     = [regex]::Match($url, 'svr_area=([^&]+)').Groups[1].Value
                    "record_id"    = [regex]::Match($url, 'record_id=([^&]+)').Groups[1].Value
                    "resources_id" = [regex]::Match($url, 'resources_id=([^&]+)').Groups[1].Value
                }

                # Add base_url to urlParams
                $urlParams.Add("base_url", $baseUrl)

                # Convert to JSON format
                $jsonOutput = ConvertTo-Json -InputObject $urlParams -Depth 5

                # Copy JSON to clipboard
                Set-Clipboard $jsonOutput

                Write-Host ""
                Write-Host "Data has been copied to clipboard. Please paste it in tracker." -ForegroundColor Green
            }
            else {
                Write-Host "No URL found." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host ""
            Write-Host "No matching entries found in the log file. Please open your Convene History first!" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Process 'Wuthering Waves.exe' is not currently running!" -ForegroundColor Red
    }
}
else {
    Write-Host "Error: Unable to check the status of 'Wuthering Waves.exe'. Make sure it's game is running!" -ForegroundColor Red
}
