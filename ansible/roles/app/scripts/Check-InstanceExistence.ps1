[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$ASCSHost,

    [Parameter(Mandatory=$true)]
    [string]$TargetHost,

    [Parameter(Mandatory=$true)]
    [int]$TargetInstanceNumber
)

$ErrorActionPreference = "Stop"

$SapControlExe = "C:\Program Files\SAP\hostctrl\exe\sapcontrol.exe"

if (-Not (Test-Path $SapControlExe)) {
    # No instances have been installed if `sapcontrol.exe` doesn't exist
    Write-Host "false"
    Write-Host "sapcontrol.exe does not exist on the system"
    [Environment]::Exit(0)
}

$InstanceList = & $SapControlExe `
    -nr 00 `
    -host "$($ASCSHost)" `
    -function GetSystemInstanceList

if ($InstanceList | Select-String -CaseSensitive "FAIL") {
    Write-Host "There was a problem getting the instance list" 
    Write-Host $InstanceList
    [Environment]::Exit(1)
}

# Successfully retrieved system instance list
if ($InstanceList | Select-String -CaseSensitive "OK") {
        
    # Instance exists
    if ($InstanceList | Select-String "$($TargetHost), $($TargetInstanceNumber)" | Select-String "GREEN") {
        Write-Host "true"
    }

    # Instance does not exist or is down
    else {
        Write-Host "false"
    }
}

Write-Host "Printing result for debugging information"
Write-Host $InstanceList