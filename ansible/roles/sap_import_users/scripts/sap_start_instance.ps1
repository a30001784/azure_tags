<#
 .SYNOPSIS
  Script to Stop SAP system
 
 .DESCRIPTION
  The script is used to stop SAP system or instance.
   
 .PARAMETER saphost
  Specifies the hostname of SAP system

 .PARAMETER sapadmuser
  SAP admin user account used to manage the SAP instance

 .PARAMETER sapadmpwd
  SAP admin user account password used to manage the SAP instance

 .PARAMETER instance
  SAP instance number that is being managed

 .PARAMETER system
  SAP System that is being managed

 .EXAMPLE
 .\sap_check_status.ps1 -saphost "azsaw****" -sapadmuser "wa*adm" -sapadmpwd "***" -instance "66" -system="Web Dispatcher"
#>

Param (
    [Parameter(Mandatory = $true)] 
    [string] 
    $saphost,
    [Parameter(Mandatory = $true)] 
    [string]
    $sapadmuser,
    [Parameter(Mandatory = $true)] 
    [string]
    $sapadmpwd,
    [Parameter(Mandatory = $true)] 
    [string]
    $instance,
    [Parameter(Mandatory = $true)] 
    [string]
    $system
) 

# Determine ASCS Server
mkdir -path C:\Packages\SAP\Logs -Force
$Path = "C:\Packages\SAP\Logs\temp.csv"
$path2 = "C:\Packages\SAP\Logs\temp2.csv"
& "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $instance -host $saphost -user $sapadmuser $sapadmpwd -function GetSystemInstanceList > $Path
get-content $Path | select -Skip 4 | set-content "$Path-temp"
move "$Path-temp" $Path -Force
$ascs=""
$values = import-csv $Path 
foreach($value in $values){
    if($value.features -match "MESSAGESERVER" -or $value.features -match "WEBDISP"){
        $ascs = $value.hostname
        $ascsinstance = $value.instanceNr.PadLeft(2,"0")
    }
}
Write-Host "The ASCS Server for $system is $ascs with instance number $ascsinstance"

# Start SAP ASCS Instance
& "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $ascsinstance -host $ascs -user $sapadmuser $sapadmpwd -function Start
Write-Host "Starting ASCS Host $ascs"

# Wait for SAP Command
Start-Sleep 10

# Wait for ASCS Instances to Start
Do {
    & "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $ascsinstance -host $ascs -user $sapadmuser $sapadmpwd -function GetSystemInstanceList > $Path2
    get-content $Path2 | select -Skip 4 | set-content "$Path2-temp"
    move "$Path2-temp" $Path2 -Force
    $check = import-csv $Path2 | where-object {($_.hostname -eq $ascs -and $_.dispstatus -match "GRAY") -or ($_.hostname -eq $ascs -and $_.dispstatus -match "YELLOW")} | Format-Table | Out-String
    }
While ($check -match "GRAY" -or $check -match "YELLOW")

# Start SAP Instance
& "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $instance -host $saphost -user $sapadmuser $sapadmpwd -function Start
Write-Host "Starting instance $instance on host $saphost"

Start-Sleep 10

# Wait for Instance to Start
Do {
    & "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $instance -host $saphost -user $sapadmuser $sapadmpwd -function GetSystemInstanceList > $Path
    get-content $Path | select -Skip 4 | set-content "$Path-temp"
    move "$Path-temp" $Path -Force
    $check = import-csv $Path | where-object {($_.hostname -eq $saphost -and $_.instanceNr -eq $instance)} | Format-Table | Out-String
    }
While ($check -match "GRAY" -or $check -match "YELLOW")

#Check SAP Instance has Started
& "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $instance -host $saphost -user $sapadmuser $sapadmpwd -function GetSystemInstanceList > $Path
get-content $Path | select -Skip 4 | set-content "$Path-temp"
move "$Path-temp" $Path -Force
$values = import-csv $Path 

foreach ($value in $values)
{
     if ($value.dispstatus -like "*GREEN*" -and $value.hostname -eq $saphost -and $value.instanceNr -eq $instance ) {
        Write-Output "$system $value.hostname is Up"
        }
    if ($value.dispstatus -like "*GRAY*" -and $value.hostname -eq $saphost -and $value.instanceNr -eq $instance ) {
        Write-Output "$system $value.hostname is Down"
        }
    if ($value.dispstatus -like "*YELLOW*" -and $value.hostname -eq $saphost -and $value.instanceNr -eq $instance ) {
        Write-Output "$system $value.hostname is Starting"
        }
}