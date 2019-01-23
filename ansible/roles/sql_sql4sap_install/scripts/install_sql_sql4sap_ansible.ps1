<#
.SYNOPSIS
  Script to install SQL using SQL4SAP
 
.DESCRIPTION
  The script is used to complete the post configuration tasks for the CRM DB build.
  The post configuration tasks are defined driven by the specifications requested by the SAP team.
  this script installs SQL using SQL4SAP.

  Note: The SQL binaries need to be present in the SQL4SAP folder and has to be replaced if SQL version needs to be changed.
   
.PARAMETER SID
Specifies the name of an SAP Instance. eg: CA1

.PARAMETER storName
Specifies the name of the storage account

.PARAMETER storName
Specifies the key of the storage account, passed as a secure string from the VSTS pipeline.

.EXAMPLE
  .\install_sql_sql4sap.ps1 -SID "***" -storName "***" -storKey "***"
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
Robocopy "X:\installFiles\51050563-RDBMS-MSSQLSRV-2014 SP1 CU1-SQL4SAP-only\51050563" "C:\Packages\SAP\SQL4SAP\" *.* /e

# Install SQL Server 2014 + SP2 + CU 11 using sql4SAP
Start-Process "C:\Packages\SAP\SQL4SAP\SQL4SAP.bat" -Verb runAs -WindowStyle Hidden -ArgumentList " -i MSSQLSERVER -u BUILTIN\Administrators /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION=install /SQLSYSADMINACCOUNTS=BUILTIN\Administrators /FEATURES=BC,BOL,Conn,SSMS,ADV_SSMS,SQLEngine,Fulltext,SDK,ADV_SSMS,SNAC_SDK /UpdateEnabled=TRUE /UpdateSource=C:\Packages\SAP\installFiles\51050563-RDBMS-MSSQLSRV-2014 SP1 CU1-SQL4SAP-only\51050563\x86-x64\Patches\X64"
Start-Sleep -s 900

# Load the assembly containing the objects used in this example
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")

# Declare Variables
$SQLServiceAccount = 'NT Service\MSSQLSERVER'
$SQLServiceAccountPassword = ''

# Get a managed computer instance
$mc = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer

# List out all sql server instnces running on this mc
foreach ($Item in $mc.Services) {$Item.Name}

# Get the default sql server datbase engine service
$svc = $mc.Services["MSSQLSERVER"]

# Stop this service
$svc.Stop()
$svc.Refresh()
while ($svc.ServiceState -ne "Stopped") {
    $svc.Refresh()
    $svc.ServiceState
}
"Service" + $svc.Name + " is now stopped"

# Change service account credentials
$svc.SetServiceAccount($SQLServiceAccount, $SQLServiceAccountPassword)

"Starting " + $svc.Name
$svc.Start()
$svc.Refresh()
while ($svc.ServiceState -ne "Running") {
    $svc.Refresh()
    $svc.ServiceState
}
$svc.ServiceState
"Service" + $svc.Name + "is now started"

# Load the assembly containing the objects used in this example
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
#Add-Type -AssemblyName "Microsoft.SqlServer.Management.SMO"

# Declare Variables
$SQLServiceAccount = 'NT Service\SQLSERVERAGENT'
$SQLServiceAccountPassword = ''

# Get a managed computer instance
$mc = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer

# List out all sql server instnces running on this mc
foreach ($Item in $mc.Services) {
    $Item.Name
}

# Get the default sql server datbase engine service
$svc2 = $mc.Services["SQLSERVERAGENT"]

# Stop this service
$svc2.Stop()
$svc2.Refresh()
while ($svc2.ServiceState -ne "Stopped") {
    $svc2.Refresh()
    $svc2.ServiceState
}
"Service" + $svc2.Name + " is now stopped"

# Change service account credentials
$svc2.SetServiceAccount($SQLServiceAccount, $SQLServiceAccountPassword)

"Starting " + $svc2.Name
$svc2.Start()
$svc2.Refresh()
while ($svc.ServiceState -ne "Running") {
    $svc2.Refresh()
    $svc2.ServiceState
}
$svc2.ServiceState
"Service" + $svc2.Name + "is now started"

Get-Service SQLSERVERAGENT | Start-Service

$Networkpath = "X:\" 
$pathExists = Test-Path -Path $Networkpath
If ($pathExists) {
Remove-PSDrive -Name X
}

Stop-Transcript