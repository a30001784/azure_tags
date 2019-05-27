        /**** Conversion for XI/PI systems in CRM ****/

-- FOR PI System conversion ::

USE $(database)

Declare @pi_source_ls nvarchar(max)
Declare @pi_target_ls nvarchar(max)
SELECT @pi_source_ls = PARNUM from $(schema).EDPP1 where PARNUM LIKE 'M%';
PRINT @pi_source_ls
Set @pi_target_ls = 'M'+RIGHT('$(database)',2)+'001'
PRINT @pi_target_ls

Update $(schema).EDIDC SET SNDPRN=@pi_target_ls WHERE SNDPRN=@pi_source_ls
Update $(schema).EDIDC SET RCVPRN=@pi_target_ls WHERE RCVPRN=@pi_source_ls
Update $(schema).EDPP1 SET PARNUM=@pi_target_ls WHERE PARNUM=@pi_source_ls
Update $(schema).SRRELROLES SET LOGSYS=@pi_target_ls WHERE LOGSYS=@pi_source_ls