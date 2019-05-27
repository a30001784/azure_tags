      /**** RUN THEM IN PARALLEL SEPARATE WINDOWS *****/

USE $(database)

Declare @crm_source_ls nvarchar(max)
Declare @crm_target_ls nvarchar(max)
SELECT @crm_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @crm_source_ls
Set @crm_target_ls = '$(database)100'
PRINT @crm_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 6 ) BEGIN UPDATE TOP(20000000) $(schema).SWW_CONTOB SET    LOGSYS = @crm_target_ls WHERE  LOGSYS = @crm_source_ls SET @BATCH=@BATCH + 1 END -- (20 mins)