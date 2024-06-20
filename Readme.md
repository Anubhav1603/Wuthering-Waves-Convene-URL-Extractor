# Convene URL Extractor

It helps in getting convene url data from wuthering waves games and gives output in **json** format


## Steps to get execute:
1) Open wuthering waves convene page
2) click on history
3) Open windows powershell as administrator
4) paste the script given below in your powershell terminal
```powershell
 if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Write-Host "Please run PowerShell as an Administrator!" -ForegroundColor Red } else { iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Anubhav1603/Wuthering-Waves-Convene-URL-Extractor/master/WutheringWavesConveneRecord.ps1").Content }
 ```