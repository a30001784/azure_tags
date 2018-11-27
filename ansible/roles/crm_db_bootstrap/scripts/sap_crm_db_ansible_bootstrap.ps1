<#
.SYNOPSIS
  Script to complete the post configuration tasks for CRM Database
 
.DESCRIPTION
  The script is used to complete the post configuration tasks for the CRM DB build.
  The post configuration tasks are defined driven by the specifications requested by the SAP team.
   
.PARAMETER SID
Specifies the name of an SAP Instance. eg: CA1

.PARAMETER storName
Specifies the name of the storage account

.PARAMETER storName
Specifies the key of the storage account, passed as a secure string from the VSTS pipeline.

.EXAMPLE
  .\sap_crm_db_ansible_bootstrap.ps1 -SID "***" -storName "***" -storKey "***"
#>

Param (
  [Parameter(Mandatory=$false)] 
  [string]$SID,

  [Parameter(Mandatory=$false)] 
  [string]$storName,

  [Parameter(Mandatory=$false)] 
  [string]$storKey
) 
# Set Error Action Preference
$ErrorActionPreference = "Stop"

# Stops the Hardware Detection Service
Stop-Service -Name ShellHWDetection 

#Initialize, Partition, Assign Drive Letter and Formatdisk
$DataDisks = Get-PhysicalDisk -CanPool $true

if($DataDisks.Count -eq 0) {
  Write-Host "[INFO] No disks available for pooling"
  Write-Host "Exiting..."
  #[Environment]::Exit(0)
}

else {
  
 # New Data Storage Pool
  New-StoragePool -FriendlyName "StoragePool" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $DataDisks
  
  # New Data Disk
  New-VirtualDisk -StoragePoolFriendlyName "StoragePool" -FriendlyName "Data" -Interleave "65536" -NumberOfColumns "12" -ResiliencySettingName simple -Size 6144GB | `
		Initialize-Disk -PartitionStyle GPT -PassThru | `
        New-Partition -DriveLetter "I" -UseMaximumSize | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -AllocationUnitSize "65536" -Confirm:$false -Force

  # New Backup Disk
	New-VirtualDisk -StoragePoolFriendlyName "StoragePool" -FriendlyName "Backup" -Interleave "65536" -NumberOfColumns "12" -ResiliencySettingName simple -UseMaximumSize | `
		Initialize-Disk -PartitionStyle GPT -PassThru | `
        New-Partition -AssignDriveLetter -UseMaximumSize | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "Backup" -AllocationUnitSize "65536" -Confirm:$false -Force
}

# Starts the Hardware Detection Service
Start-Service -Name ShellHWDetection 

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
Robocopy "X:\installFiles\" "C:\Packages\SAP\" *.cab
Robocopy "X:\installFiles\MS-Visual-C-2005-SP1-Redistributable" "C:\Packages\SAP\"

# Adding AD Domain Group to Local Administrator Group
$group = "Administrators";
$groupObj =[ADSI]"WinNT://./$group,group" 
$membersObj = @($groupObj.psbase.Invoke("Members")) 
$GrouptoAdd = "Func-SAP-Testing-MSDN-Testing"
$members = ($membersObj | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)})

If ($members -contains $GrouptoAdd) {
      Write-Host "$GrouptoAdd exists in the group $group"
 } Else {
Write-Host ""
Write-Host "Adding Domain Group $GrouptoAdd to Local Administrator Group" -ForegroundColor Yellow
Write-Host ""

$GroupObj = [ADSI]"WinNT://localhost/Administrators"
$GroupObj.Add("WinNT://agl.int/$GrouptoAdd")
}

# Install .net 3.5
dism /online /enable-feature /featurename:NetFx3 /All /Source:C:\Packages\SAP\

# Install Microsoft Visual C++ 2005 SP1
Invoke-Command -ScriptBlock {&"C:\Packages\SAP\vcredist_x64.exe" /q}

# Disable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Disable IE Enhanced Security Configuration
$adminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$userKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $adminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $userKey -Name "IsInstalled" -Value 0
#Stop-Process -Name Explorer
Write-Host "IE Enhanced Security Configuration (ESC) has been disabled."

# Create directory structure for SAP database
New-Item -Path I:\"$SID"\"$SID"LOG -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA1 -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA2 -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA3 -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA4 -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA5 -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA6 -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA7 -ItemType "directory" -Force
New-Item -Path I:\"$SID"\"$SID"DATA8 -ItemType "directory" -Force

$Networkpath = "X:\" 
$pathExists = Test-Path -Path $Networkpath
If ($pathExists) {
Remove-PSDrive -Name X
}