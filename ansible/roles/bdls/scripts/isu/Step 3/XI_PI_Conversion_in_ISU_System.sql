		/**** Conversion for XI/PI systems ****/

USE $(database)

Declare @xi_source_ls nvarchar(max)
Declare @xi_target_ls nvarchar(max)
SELECT @xi_source_ls = PARNUM from $(schema).EDPP1 where PARNUM LIKE 'X%';
PRINT @xi_source_ls
Set @xi_target_ls = 'X'+RIGHT('$(database)',2)+'001'
PRINT @xi_target_ls

Declare @pi_source_ls nvarchar(max)
Declare @pi_target_ls nvarchar(max)
SELECT @pi_source_ls = PARNUM
from $(schema)
.EDPP1 where PARNUM LIKE 'M%';
PRINT @pi_source_ls
Set @pi_target_ls = 'M'+RIGHT('$(database)',2)+'001'
PRINT @pi_target_ls

-- FOR XI Syetem conversion ::

Update $(schema).EDP13 SET RCVPRN =@xi_target_ls WHERE RCVPRN= @xi_source_ls   
Update $(schema).TBD05 SET RCVSYSTEM = @xi_target_ls WHERE RCVSYSTEM = @xi_source_ls                                           
Update $(schema).EDP21 SET SNDPRN = @xi_target_ls WHERE SNDPRN = @xi_source_ls                               
Update $(schema).EDPP1 SET PARNUM = @xi_target_ls WHERE PARNUM = @xi_source_ls
Update $(schema).EDIDC SET RCVPRN = @xi_target_ls WHERE RCVPRN = @xi_source_ls -- 11087136 entries
Update $(schema).EDIDC SET SNDPRN = @xi_target_ls WHERE SNDPRN = @xi_source_ls -- 2505655 entries 
Update $(schema).SRRELROLES SET LOGSYS = @xi_target_ls WHERE LOGSYS = @xi_source_ls -- 1358990 entries


Update $(schema).EDP13 SET RCVPRN = @pi_target_ls WHERE RCVPRN = @pi_source_ls  
Update $(schema).EDPP1 SET PARNUM = @pi_target_ls WHERE PARNUM = @pi_source_ls 
Update $(schema).EDIDC SET RCVPRN = @pi_target_ls WHERE RCVPRN = @pi_source_ls  -- 21783444 entries 
                                       