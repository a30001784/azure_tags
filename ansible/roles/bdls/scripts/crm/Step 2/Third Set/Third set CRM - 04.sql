        /**** RUN THEM IN PARALLEL SEPARATE WINDOWS *****/
USE $(database)

Declare @crm_source_ls nvarchar(max)
Declare @crm_target_ls nvarchar(max)
SELECT @crm_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @crm_source_ls
Set @crm_target_ls = '$(database)100'
PRINT @crm_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 3 ) BEGIN UPDATE TOP(2000000) $(schema).CRMM_BUT_FRG0050  SET  HOME_SYSTEM = @crm_target_ls WHERE  HOME_SYSTEM = @crm_source_ls SET @BATCH=@BATCH + 1 END -- (1 min)
