        /**** RUN THEM IN PARALLEL SEPARATE WINDOWS *****/

DECLARE @BATCH INT=1 WHILE( @BATCH <= 20 ) BEGIN UPDATE TOP(2000000) ccu.CRMM_BUT_LNK0140 SET HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (6 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 20 ) BEGIN UPDATE TOP(2000000) ccu.CRMM_BUT_LNK0010 SET HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (7 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 7 ) BEGIN UPDATE TOP(2000000) ccu.ZCRMD_ORDERADM_H SET LOGICAL_SYSTEM = 'CCU100' WHERE  LOGICAL_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (4 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 3 ) BEGIN UPDATE TOP(2000000) ccu.CRMM_BUT_FRG0050  SET  HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (1 min)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 2 ) BEGIN UPDATE TOP(2000000) ccu.EDIDC  SET  RCVPRN = 'CCU100' WHERE  RCVPRN = 'CP1100' SET @BATCH=@BATCH + 1 END -- (4 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 6 ) BEGIN UPDATE TOP(2000000) ccu.CRMM_BABR  SET  HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (15 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 6 ) BEGIN UPDATE TOP(2000000) ccu.CRMM_BUAG SET   HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (15 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 7 ) BEGIN UPDATE TOP(2000000) ccu.COMM_PR_FRG_REL  SET  LOGSYS = 'CCU100' WHERE  LOGSYS = 'CP1100' SET @BATCH=@BATCH + 1 END -- (3 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 5 ) BEGIN UPDATE TOP(2000000) ccu.CRMM_BUT_FRG0040  SET   HOME_SYSTEM = 'CCU100' WHERE  HOME_SYSTEM = 'CP1100' SET @BATCH=@BATCH + 1 END -- (2 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 2 ) BEGIN UPDATE TOP(20000000) ccu.CRMD_BRELVONAI   SET LOGSYS_B = 'ICU100' WHERE  LOGSYS_B = 'IP1100' SET @BATCH=@BATCH + 1 END -- (10 mins)
DECLARE @BATCH INT=1 WHILE( @BATCH <= 3 ) BEGIN UPDATE TOP(2000000) ccu.CRMD_BRELVONAE  SET  LOGSYS_B_SEL = 'ICU100' WHERE  LOGSYS_B_SEL = 'IP1100' SET @BATCH=@BATCH + 1 END -- ( 12 mins)
