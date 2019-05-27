       /****  RUN THEM IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @crm_source_ls nvarchar(max)
Declare @crm_target_ls nvarchar(max)
Set @crm_target_ls = 'C'+RIGHT('$(database)',2)+'100'
PRINT @crm_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 1 ) BEGIN UPDATE TOP(20000000) $(schema).SRRELROLES   SET  LOGSYS = @crm_target_ls WHERE  LOGSYS = '$(crm_source_ls)' SET @BATCH=@BATCH + 1 END -- 14587581/(16 mins)