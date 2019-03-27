<#
.SYNOPSIS
  Script to complete the post configuration tasks for CRM Database
 
.DESCRIPTION
  The script is used to complete the post configuration tasks for the CRM DB build.
  The post configuration tasks are defined driven by the specifications requested by the SAP team.
   
.PARAMETER SID
Specifies the name of an SAP Instance. eg: CA1

.EXAMPLE
  .\sap_crm_db_sql_config_01.ps1 -SID "***"
#>

Param (
    [Parameter(Mandatory = $false)] 
    [string]
    $SID,

    [Parameter(Mandatory = $false)] 
    [string] 
    $storName,

    [Parameter(Mandatory = $false)] 
    [string] 
    $storKey
) 
# Set Error Action Preference
$ErrorActionPreference = "Stop"

Start-Transcript -path C:\logs\Ansible\sql4sap.txt

# Mount Azure file Share to Z Drive 
$Networkpath = "X:\" 
$pathExists = Test-Path -Path $Networkpath

If ($pathExists) {
    Remove-PSDrive -Name X
}

$acctKey = ConvertTo-SecureString -String $storKey -AsPlainText -Force 
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$storName", $acctKey 
New-PSDrive -Name X -PSProvider FileSystem -Root "\\aaasapautomationsa.file.core.windows.net\sapptia" -Credential $credential -Persist

# Copy Azure FileStore to Local Packages Dir 
Robocopy "X:\sqlScripts" "C:\Packages\SAP\sqlScripts\" *.* /e

# Copy NTRights Tool 
Robocopy "X:\installFiles\" "C:\Packages\SAP" ntrights.exe

# Sql Script to rename Logical File names within SQL
$DBScriptFile = "C:\Packages\SAP\sqlScripts\sap_crm_post_config_01.sql"
Sqlcmd -i $DBScriptFile -v database = "$SID"
Start-Sleep -s 30

# SQL Script to take database offline
$DBScriptFile = "C:\Packages\SAP\sqlScripts\sap_crm_post_config_02.sql"
Sqlcmd -i $DBScriptFile -v database = "$SID"
Start-Sleep -s 15

#Rename Files at OS Level

# Set SQL Data Directory
$directory = "I:\$SID"

# Get files only
$ndfs = Get-ChildItem $directory -Filter *.ndf -Recurse| where {$_.psiscontainer -eq $false}

#loop through each file name
foreach ($n in $ndfs){
    $suffix = ($n.Name.Substring(3, $n.Name.length - 3))
    Rename-Item $n.FullName -NewName ($SID+"$suffix")
    Write-Host $n.FullName
}

$ldfs = Get-ChildItem $directory -Filter *.ldf -Recurse| where {$_.psiscontainer -eq $false}

#loop through each file name
foreach ($l in $ldfs){
    $suffix = ($l.Name.Substring(3, $l.Name.length - 3))
    Rename-Item $l.FullName -NewName ($SID+"$suffix")
    Write-Host $l.FullName
}

$mdfs = Get-ChildItem $directory -Filter *.mdf -Recurse| where {$_.psiscontainer -eq $false}

#loop through each file name
foreach ($m in $mdfs){
    $suffix = ($m.Name.Substring(3, $m.Name.length - 3))
    Rename-Item $m.FullName -NewName ($SID+"$suffix")
    Write-Host $m.FullName
}

# SQL script to take database Online
$DBScriptFile = "C:\Packages\SAP\sqlScripts\sap_crm_post_config_03.sql"
Sqlcmd -i $DBScriptFile -v database = "$SID"
Start-Sleep -s 15

# SQL Script to move temp db files and create additional temp db files
$DBScriptFile = "C:\Packages\SAP\sqlScripts\sap_crm_post_config_04.sql"
Sqlcmd -i $DBScriptFile -v database = "$SID"
Start-Sleep -s 360

# Load the assembly containing the objects used in this example
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")

# Get a managed computer instance
$mc = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer

# List out all sql server instnces running on this mc
foreach ($Item in $mc.Services) {$Item.Name}

# Get the default sql server datbase engine service
$svc = $mc.Services["MSSQLSERVER"]

# Stop MSSQLSERVICE 
$svc.Stop()
$svc.Refresh()
while ($svc.ServiceState -ne "Stopped") {
    $svc.Refresh()
    $svc.ServiceState
}
"Service" + $svc.Name + " is now stopped"

# Stop MSSQLSERVICE 

"Starting " + $svc.Name
$svc.Start()
$svc.Refresh()
while ($svc.ServiceState -ne "Running") {
    $svc.Refresh()
    $svc.ServiceState
}
$svc.ServiceState
"Service" + $svc.Name + "is now started"

# Remove temp DB Files from C Drive
Remove-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\temp*"

# Set Local Security Policy

cd C:\Packages\SAP
#get the name of the sql server local group 
$sqlgroup= net localgroup|findstr SQLServerMSSQLUser 
#if we haven't found a group with this name, default to our service account (should be a cluster) 
if (!$sqlgroup) {$sqlgroup="NT Service\MSSQLSERVER"} 
.\Ntrights -u $sqlgroup +r SeLockMemoryPrivilege 
.\Ntrights -u $sqlgroup +r SeManageVolumePrivilege 

# Add Traceflag
$Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQLServer\Parameters"
If  ( -Not ( Test-Path "Registry::$Key")){New-Item -Path "Registry::$Key" -ItemType RegistryKey -Force}
Set-ItemProperty -path "Registry::$Key" -Name "SQLArg7" -Type "String" -Value "-T617"
Set-ItemProperty -path "Registry::$Key" -Name "SQLArg8" -Type "String" -Value "-T1117"
Set-ItemProperty -path "Registry::$Key" -Name "SQLArg9" -Type "String" -Value "-T1118"
Set-ItemProperty -path "Registry::$Key" -Name "SQLArg10" -Type "String" -Value "-T2371"
Set-ItemProperty -path "Registry::$Key" -Name "SQLArg11" -Type "String" -Value "-T3051"
Set-ItemProperty -path "Registry::$Key" -Name "SQLArg12" -Type "String" -Value "-T8075"
Set-ItemProperty -path "Registry::$Key" -Name "SQLArg13" -Type "String" -Value "-T8080"

# Restart SQL Services and Wait for it to finish
Restart-Service MSSQLSERVER -Force
Restart-Service SQLSERVERAGENT -Force
Start-Sleep -s 15

# SQL Server Configuration Options
$DBScriptFile = "C:\Packages\SAP\sqlScripts\sap_crm_post_config_05.sql"
Sqlcmd -i $DBScriptFile -v database = "$SID"
Start-Sleep -s 15

$Networkpath = "X:\" 
$pathExists = Test-Path -Path $Networkpath
If ($pathExists) {
Remove-PSDrive -Name X
}