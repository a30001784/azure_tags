     /****  RUN IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @crm_source_ls nvarchar(max)
Declare @crm_target_ls nvarchar(max)
Set @crm_target_ls = 'C'+RIGHT('$(database)',2)+'100'
PRINT @crm_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 5 ) BEGIN UPDATE TOP(2000000) $(schema).BDOC_TRACK  SET  LOG_SYSTEM = @crm_target_ls WHERE  LOG_SYSTEM = '$(crm_source_ls)' SET @BATCH=@BATCH + 1 END -- 9616312/(6/5 mins)