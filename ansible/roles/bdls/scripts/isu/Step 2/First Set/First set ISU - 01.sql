       /****  RUN THEM IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
SELECT @isu_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @isu_source_ls
Set @isu_target_ls = '$(database)100'
PRINT @isu_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 8 ) BEGIN UPDATE TOP(20000000) $(schema).EDIDC  SET  RCVPRN = @isu_target_ls WHERE  RCVPRN = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 149232321/(1hour 15 mins)