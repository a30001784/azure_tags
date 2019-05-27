USE $(database)

Declare @isu_source_ls nvarchar(max)
Declare @isu_target_ls nvarchar(max)
Set @isu_target_ls = 'I'+RIGHT('$(database)',2)+'100'
PRINT @isu_target_ls

DECLARE @BATCH3 INT=1 WHILE( @BATCH3 <= 7 ) BEGIN UPDATE TOP (20000000) $(schema).SRRELROLES WITH (READPAST) SET   LOGSYS = @isu_target_ls WHERE CLIENT ='100' and LOGSYS = '$(isu_source_ls)' and UTCTIME between '20130101000000' and '20171231235959' SET @BATCH3=@BATCH3 + 1 END --133536272 (2 hours 5 mins)