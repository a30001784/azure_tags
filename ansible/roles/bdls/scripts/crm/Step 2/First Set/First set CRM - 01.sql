/**** BDLS Post Config - Step 02 - First Set - Script 01/08 *****/

USE $(database)

Declare @crm_source_ls nvarchar(max)
Declare @crm_target_ls nvarchar(max)
SELECT @crm_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @crm_source_ls
Set @crm_target_ls = '$(database)100'
PRINT @crm_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 22 ) BEGIN UPDATE TOP(20000000) $(schema).CRMD_ORDERADM_H SET    LOGICAL_SYSTEM = @crm_target_ls WHERE  LOGICAL_SYSTEM = @crm_source_ls SET @BATCH=@BATCH + 1 END -- (1 hour 45 mins)