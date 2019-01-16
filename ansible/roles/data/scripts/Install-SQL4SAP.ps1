$value = Test-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL"
if (-Not $value) {
    Start-Process "C:\Packages\SAP\SQL4SAP\SQL4SAP.bat" -Verb runAs -WindowStyle Hidden -ArgumentList " -i MSSQLSERVER -u BUILTIN\Administrators /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION=install /SQLSYSADMINACCOUNTS=BUILTIN\Administrators /FEATURES=BC,BOL,Conn,SSMS,ADV_SSMS,SQLEngine,Fulltext,SDK,ADV_SSMS,SNAC_SDK /UpdateEnabled=TRUE /UpdateSource=C:\Packages\SAP\installFiles\51050563-RDBMS-MSSQLSRV-2014 SP1 CU1-SQL4SAP-only\51050563\x86-x64\Patches\X64"
}