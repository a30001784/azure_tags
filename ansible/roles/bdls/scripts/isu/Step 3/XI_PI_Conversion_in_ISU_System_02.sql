		/**** Conversion for XI/PI systems ****/

USE $(database)

Declare @pi_source_ls nvarchar(max)
Declare @pi_target_ls nvarchar(max)
SELECT @pi_source_ls = PARNUM from $(schema).EDPP1 where PARNUM LIKE 'M%';
PRINT @pi_source_ls
Set @pi_target_ls = 'M'+RIGHT('$(database)',2)+'001'
PRINT @pi_target_ls

-- FOR PI System conversion ::

Update $(schema).EDP13 SET RCVPRN = @pi_target_ls WHERE RCVPRN = @pi_source_ls  
Update $(schema).EDPP1 SET PARNUM = @pi_target_ls WHERE PARNUM = @pi_source_ls 
Update $(schema).EDIDC SET RCVPRN = @pi_target_ls WHERE RCVPRN = @pi_source_ls  -- 21783444 entries 