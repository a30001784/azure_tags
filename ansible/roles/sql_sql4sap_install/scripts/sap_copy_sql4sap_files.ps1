<#
.SYNOPSIS
  Script to copy files from blob to machine
 
.DESCRIPTION
  The script is used to complete the post configuration tasks for SAP SQL.
  The post configuration tasks are defined driven by the specifications requested by the SAP team.
  the script copies the sql scripts and binaries required for the post configuration.
   
.PARAMETER storName
Specifies the name of Storage Account

.PARAMETER storKey
Specifies the key of Storage Account

.EXAMPLE
  .\sap_sql_copy_blob_files.ps1 -storName "***" -storKey "***"
#>

Param (
    [Parameter(Mandatory = $false)] 
    [string] 
    $storName,

    [Parameter(Mandatory = $false)] 
    [string] 
    $storKey
) 
# Set Error Action Preference
$ErrorActionPreference = "Stop"

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
Robocopy "X:\installFiles\MS-Visual-C-2005-SP1-Redistributable" "C:\Packages\SAP\"

# Install Microsoft Visual C++ 2005 SP1
#Invoke-Command -ScriptBlock {&"C:\Packages\SAP\vcredist_x64.exe" /q}