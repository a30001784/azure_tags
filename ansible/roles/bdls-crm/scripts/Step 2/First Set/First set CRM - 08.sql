/**** BDLS Post Config - Step 02 - First Set - Script 08/08 *****/

USE $(database)

Declare @bw_source_ls nvarchar(max)
Declare @bw_target_ls nvarchar(max)
SELECT @bw_source_ls = PARNUM from $(schema).EDPP1 WHERE PARNUM LIKE 'B%'
Print @bw_source_ls
Set @bw_target_ls = 'B'+RIGHT('$(database)',2)+'001'
PRINT @bw_target_ls

DECLARE @BATCH INT=1 WHILE( @BATCH <= 3 ) BEGIN UPDATE TOP(2000000) $(schema).EDIDC  SET  RCVPRN =  @bw_target_ls WHERE  RCVPRN = @bw_source_ls SET @BATCH=@BATCH + 1 END -- (5 mins)