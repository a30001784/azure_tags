<#
.SYNOPSIS
  Script to install SQL using SQL4SAP
 
.DESCRIPTION
  The script is used to complete the post configuration tasks for the CRM DB build.
  The post configuration tasks are defined driven by the specifications requested by the SAP team.
  this script installs SQL using SQL4SAP.

  Note: The SQL binaries need to be present in the SQL4SAP folder and has to be replaced if SQL version needs to be changed.
   
.EXAMPLE
  .\Install-SQL4SAP.ps1
#>

# Set Error Action Preference
$ErrorActionPreference = "Stop"

Start-Transcript -path C:\Logs\sql4sap.txt

# Install SQL Server 2014 + SP2 + CU 11 using sql4SAP
Start-Process "C:\Packages\SAP\SQL4SAP\SQL4SAP.bat" -Verb runAs -WindowStyle Hidden -ArgumentList " -i MSSQLSERVER -u BUILTIN\Administrators /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION=install /SQLSYSADMINACCOUNTS=BUILTIN\Administrators /FEATURES=BC,BOL,Conn,SSMS,ADV_SSMS,SQLEngine,Fulltext,SDK,ADV_SSMS,SNAC_SDK /UpdateEnabled=TRUE /UpdateSource=C:\Packages\SAP\SQL4SAP\x86-x64\Patches\X64"
