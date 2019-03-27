<#
.SYNOPSIS
  Script to copy files from blob to machine
 
.DESCRIPTION
  The script is used to copy the commvault media agent / sql agent files.
  It checks if the host has commvault installed and installs cv sql agent if required.
     
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

#Copy Commvault Client packages to Local Packages Dir 
#Copy-Item -Path "X:\Commvault SQL Client Packages" -Destination "C:\Packages\" -Recurse -Force
Robocopy "X:\Commvault SQL Client Packages" "C:\Packages\Commvault\" *.* /e

#Copy Commvault Restore Scripts
Robocopy "X:\CV Restore" "C:\Packages\Commvault\Restore" *.* /e

#Check if Commvault SQL Agent is Installed.
$cvsa = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object DisplayName -Like "*SQLServeriAgent*"
if (!$cvsa) {
  Write-Host "CommVault SQL Agent Not Installed! Installing SQL Agent.."

  #Install CommVault SQL Agent
  Start-Process "C:\Packages\Commvault\CV_SQL_WinX64\Setup.exe" /silent -wait
}

# #Submit Database Restore Job to CommVault
# Start-Process "C:\Packages\CommVault\Restore\cv_crm_restore.bat" /silent -wait

#Remove Network Drive
Remove-PSDrive -Name X