# Convene URL Extractor
Automatically detects the wuthering waves game location and gets the convene data.


## Steps to get execute:
1) Open wuthering waves convene page
2) click on history
3) Open windows Terminal as administrator
4) paste the script given below in your Terminal terminal
```powershell
 if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Write-Host "Please run Terminal as an Administrator!" -ForegroundColor Red } else { iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Anubhav1603/Wuthering-Waves-Convene-URL-Extractor/master/WutheringWavesConveneRecord.ps1").Content }
 ```