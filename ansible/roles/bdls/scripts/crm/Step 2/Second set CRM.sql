      /**** RUN THEM IN PARALLEL SEPARATE WINDOWS *****/

DECLARE @BATCH INT=1 WHILE( @BATCH <= 6 ) BEGIN UPDATE TOP(20000000) ccu.SWW_CONTOB SET    LOGSYS = 'CCU100' WHERE  LOGSYS = 'CP1100' SET @BATCH=@BATCH + 1 END -- (20 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 26 ) BEGIN UPDATE TOP(2000000) ccu.CRMD_ORDERADM_I SET    LOG_SYSTEM_EXT = 'CCU100' WHERE  LOG_SYSTEM_EXT = 'CP1100' SET @BATCH=@BATCH + 1 END -- (13 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 18 ) BEGIN UPDATE TOP(2000000) ccu.CRMM_BUT_FRG0100 SET    HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (8 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 11 ) BEGIN UPDATE TOP(2000000) ccu.GEOLOC SET    ADDRLOGSYS = 'CCU100' WHERE  ADDRLOGSYS = 'CP1100' SET @BATCH=@BATCH + 1 END -- (6 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 4 ) BEGIN UPDATE TOP(2000000) ccu.BUT_FRG0010  SET  HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (2 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 4 ) BEGIN UPDATE TOP(2000000) ccu.COMM_PRPRDCATR   SET  LOGSYS = 'CCU100' WHERE  LOGSYS = 'CP1100' SET @BATCH=@BATCH + 1 END -- (2 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 4 ) BEGIN UPDATE TOP(2000000) ccu.COMM_PRODUCT   SET LOGSYS = 'CCU100' WHERE  LOGSYS = 'CP1100' SET @BATCH=@BATCH + 1 END -- (2 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 12 ) BEGIN UPDATE TOP(2000000) ccu.EDIDC  SET  SNDPRN = 'CCU100' WHERE  SNDPRN = 'CP1100' SET @BATCH=@BATCH + 1 END -- (15 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 1 ) BEGIN UPDATE TOP(200000) ccu.SRRELROLES   SET  LOGSYS = 'BCU001' WHERE  LOGSYS = 'BP1001' SET @BATCH=@BATCH + 1 END --