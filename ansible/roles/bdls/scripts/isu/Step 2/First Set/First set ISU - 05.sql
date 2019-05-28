       /****  RUN THEM IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
SELECT @isu_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @isu_source_ls
Set @isu_target_ls = '$(database)100'
PRINT @isu_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 1 ) BEGIN UPDATE TOP(1000000) $(schema).BUT_FRG0010  SET  HOME_SYSTEM = @isu_target_ls WHERE  HOME_SYSTEM = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 963069/(1 min)