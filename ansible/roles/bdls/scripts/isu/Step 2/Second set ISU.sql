     /****  RUN IN PARALLEL SEPARATE WINDOWS  *****/

USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
SELECT @isu_source_ls = LOGSYS FROM $(schema).T000 WHERE MANDT = 100;
PRINT @isu_source_ls
Set @isu_target_ls = '$(database)100'
PRINT @isu_target_ls

Declare @bw_source_ls nvarchar(max)
Declare @bw_target_ls nvarchar(max)
SELECT @bw_source_ls = PARNUM from $(schema).EDPP1 WHERE PARNUM LIKE 'B%'
Print @bw_source_ls
Set @bw_target_ls = 'B'+RIGHT('$(database)',2)+'001'
PRINT @bw_target_ls

Declare @crm_source_ls nvarchar(max)
Declare @crm_target_ls nvarchar(max)
Set @crm_target_ls = 'C'+RIGHT('$(database)',2)+'100'
PRINT @crm_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 5 ) BEGIN UPDATE TOP(20000000) $(schema).EMMA_CASE  SET  LOGSYS = @isu_target_ls WHERE  LOGSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END --56801239/(25 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 3 ) BEGIN UPDATE TOP(2000000) $(schema).DFKKKO  SET  AWSYS = @isu_target_ls WHERE  AWSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 5639911/(12/9 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 3 ) BEGIN UPDATE TOP(20000000) $(schema).EMMA_HDR  SET  LOGSYS = @isu_target_ls WHERE  LOGSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 35512454/(15/11 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 5 ) BEGIN UPDATE TOP(2000000) $(schema).BDOC_TRACK  SET  LOG_SYSTEM = @crm_target_ls WHERE  LOG_SYSTEM = '$(crm_source_ls)' SET @BATCH=@BATCH + 1 END -- 9616312/(6/5 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 2 ) BEGIN UPDATE TOP(20000000) $(schema).SWW_CONTOB  SET  LOGSYS = @isu_target_ls WHERE  LOGSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 3939763/(3/2 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 7 ) BEGIN UPDATE TOP(2000000) $(schema).GEOLOC  SET  ADDRLOGSYS = @isu_target_ls WHERE  ADDRLOGSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 12302326/(17/14 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 4 ) BEGIN UPDATE TOP(2000000) $(schema).DFKKMKO  SET  AWSYS = @isu_target_ls WHERE  AWSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 6575432/(5/3 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 4 ) BEGIN UPDATE TOP(2000000) $(schema).VBRK  SET  LOGSYS = @isu_target_ls WHERE  LOGSYS = @isu_source_ls SET @BATCH=@BATCH + 1 END -- 6575432/(5/3 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 2 ) BEGIN UPDATE TOP(200000) $(schema).EDIDC  SET  RCVPRN = @bw_target_ls WHERE  RCVPRN = @bw_source_ls SET @BATCH=@BATCH + 1 END -- 12 mins
DECLARE @BATCH INT=1 WHILE( @BATCH <= 2 ) BEGIN UPDATE TOP(200000) $(schema).SRRELROLES   SET  LOGSYS = @bw_target_ls WHERE  LOGSYS = @bw_source_ls SET @BATCH=@BATCH + 1 END -- 15 mins