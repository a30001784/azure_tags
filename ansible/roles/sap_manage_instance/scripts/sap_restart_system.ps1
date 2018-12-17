<#
 .SYNOPSIS
  Script to Start SAP system
 
 .DESCRIPTION
  The script is used to start SAP system or instance.
   
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



# Determine instance number based on host and SID
$instnr = Get-Service -Name ("SAP"+$system+"*") -ComputerName $saphost
ForEach($inst in $instnr){
$in = $inst
$instance = $in.DisplayName.Substring(($in.DisplayName.Length-2),2)
}

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

# Restart SAP System
& "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $instance -host $saphost -user $sapadmuser $sapadmpwd -function RestartSystem
start-sleep 60

# Wait for all SAP Instances to Restart
Do {
    & "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $instance -host $saphost -user $sapadmuser $sapadmpwd -function GetSystemInstanceList > $Path
    get-content $Path | select -Skip 4 | set-content "$Path-temp"
    move "$Path-temp" $Path -Force
    $check = import-csv $Path | where-object {$_.dispstatus -match "GRAY" -or $_.dispstatus -match "YELLOW"} | Format-Table | Out-String
    }
While ($check -match "GRAY" -or $check -match "YELLOW")

# check is all SAP Instances have Started

& "C:\Program Files\SAP\hostctrl\exe\sapcontrol" -nr $instance -host $saphost -user $sapadmuser $sapadmpwd -function GetSystemInstanceList > $Path
get-content $Path | select -Skip 4 | set-content "$Path-temp"
move "$Path-temp" $Path -Force
$values = import-csv $Path 

foreach ($value in $values)
{
     if ($value.dispstatus -like "*GREEN*") {
        Write-Output "$system $value.hostname is Up"
        }
    if ($value.dispstatus -like "*GRAY*") {
        Write-Output "$system $value.hostname is Down"
        }
    if ($value.dispstatus -like "*YELLOW*") {
        Write-Output "$system $value.hostname is Starting"
        }
}