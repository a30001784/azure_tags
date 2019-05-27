        /**** Conversion for XI/PI systems in CRM ****/

USE $(database)

-- FOR XI System conversion ::

Declare @xi_source_ls nvarchar(max)
Declare @xi_target_ls nvarchar(max)
SELECT @xi_source_ls = PARNUM from $(schema).EDPP1 where PARNUM LIKE 'X%';
PRINT @xi_source_ls
Set @xi_target_ls = 'X'+RIGHT('$(database)',2)+'001'
PRINT @xi_target_ls

Update $(schema).SRRELROLES SET LOGSYS = @xi_target_ls where LOGSYS = @xi_source_ls -- 432080
Update $(schema).EDIDC SET SNDPRN =@xi_target_ls where SNDPRN =@xi_source_ls -- 1151096
Update $(schema).EDIDC SET RCVPRN =@xi_target_ls where RCVPRN =@xi_source_ls -- 1151096
Update $(schema).BDAUDQUEUE SET RCV_SYSTEM =@xi_target_ls where RCV_SYSTEM =@xi_source_ls -- 49893
