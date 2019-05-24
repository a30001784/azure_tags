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

$InstanceList = & "C:\\Program Files\\SAP\\hostctrl\\exe\\sapcontrol" `
    -nr 00 `
    -host "$($ASCSHost)" `
    -function GetSystemInstanceList

if ($InstanceList | Select-String "FAIL") {
    Write-Host "There was a problem getting the instance list" 
    [Environment]::Exit(1)
}
elseif ($InstanceList | Select-String "$($TargetHost), $($TargetInstanceNumber)" | Select-String GREEN) {
    Write-Host "true"
}
else {
    Write-Host "false"
}