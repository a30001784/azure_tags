     /****  RUN IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
SELECT @isu_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @isu_source_ls
Set @isu_target_ls = '$(database)100'
PRINT @isu_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 7 ) BEGIN UPDATE TOP(2000000) $(schema).GEOLOC  SET  ADDRLOGSYS = @isu_target_ls WHERE  ADDRLOGSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 12302326/(17/14 mins)