# Convene URL Extractor
Automatically detects the wuthering waves game location and gets the convene url data.


## Steps to execute:
1) Open wuthering waves convene page
2) click on history
3) Open any terminal
4) paste the script given below in your terminal
```powershell
 if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Write-Host "Please run terminal with administrator permission!" -ForegroundColor Red } else { iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Anubhav1603/Wuthering-Waves-Convene-URL-Extractor/master/WutheringWavesConveneRecord.ps1").Content }
 ```