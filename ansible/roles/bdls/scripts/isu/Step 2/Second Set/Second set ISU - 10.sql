     /****  RUN IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @bw_source_ls nvarchar(max)
Declare @bw_target_ls nvarchar(max)
SELECT @bw_source_ls = PARNUM from $(schema).EDPP1 WHERE PARNUM LIKE 'B%'
Print @bw_source_ls
Set @bw_target_ls = 'B'+RIGHT('$(database)',2)+'001'
PRINT @bw_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 2 ) BEGIN UPDATE TOP(200000) $(schema).SRRELROLES   SET  LOGSYS = @bw_target_ls WHERE  LOGSYS = @bw_source_ls SET @BATCH=@BATCH + 1 END -- 15 mins