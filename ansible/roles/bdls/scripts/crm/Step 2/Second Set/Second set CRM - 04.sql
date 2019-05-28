      /**** RUN THEM IN PARALLEL SEPARATE WINDOWS *****/

USE $(database)

Declare @crm_source_ls nvarchar(max)
Declare @crm_target_ls nvarchar(max)
SELECT @crm_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @crm_source_ls
Set @crm_target_ls = '$(database)100'
PRINT @crm_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 11 ) BEGIN UPDATE TOP(2000000) $(schema).GEOLOC SET    ADDRLOGSYS = @crm_target_ls WHERE  ADDRLOGSYS = @crm_source_ls SET @BATCH=@BATCH + 1 END -- (6 mins)
