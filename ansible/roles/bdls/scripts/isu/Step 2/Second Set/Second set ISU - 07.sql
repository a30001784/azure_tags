     /****  RUN IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
SELECT @isu_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @isu_source_ls
Set @isu_target_ls = '$(database)100'
PRINT @isu_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 4 ) BEGIN UPDATE TOP(2000000) $(schema).DFKKMKO  SET  AWSYS = @isu_target_ls WHERE  AWSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 6575432/(5/3 mins)