        /**** RUN THEM IN PARALLEL SEPARATE WINDOWS *****/
USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
Set @isu_target_ls = 'I'+RIGHT('$(database)',2)+'100'
PRINT @isu_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 2 ) BEGIN UPDATE TOP(20000000) $(schema).CRMD_BRELVONAI   SET LOGSYS_B = @isu_target_ls WHERE  LOGSYS_B = '$(isu_source_ls)' SET @BATCH=@BATCH + 1 END -- (10 mins)
