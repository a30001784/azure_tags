<#
.SYNOPSIS
  Script to rename database file names based on SID
 
.DESCRIPTION
  The script is used to complete the post configuration tasks for the CRM DB build.
  The post configuration tasks are defined driven by the specifications requested by the SAP team.
   
.PARAMETER SID
Specifies the name of an SAP Instance. eg: CA1

.EXAMPLE
  .\sap_rename_db_file -SID "***"
#>

Param (
    [Parameter(Mandatory = $true)]
    [string]
    $SID
) 
# Set Dir
$directory = "I:\$SID"

#loop through each file name
foreach ($file in (Get-ChildItem $directory -File -Recurse) ) {
   $suffix = ($file.Name.Substring(3, $file.Name.length - 3))
   Rename-Item $file.FullName -NewName "$($SID)$($suffix)"
  }