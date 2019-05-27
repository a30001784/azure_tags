/**** BDLS Post Config - Step 02 - First Set - Script 07/08 *****/

USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
Set @isu_target_ls = 'I'+RIGHT('$(database)',2)+'100'
PRINT @isu_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 5 ) BEGIN UPDATE TOP(2000000) $(schema).COMM_PRODUCT   SET  LOGSYS = @isu_target_ls WHERE  LOGSYS = '$(isu_source_ls)' SET @BATCH=@BATCH + 1 END -- (2 mins)