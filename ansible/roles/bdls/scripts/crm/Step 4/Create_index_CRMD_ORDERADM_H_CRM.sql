USE $(database)
GO
/** 4 hours 55 mins for Clustered index and 2.20 hours for rest**/
/****** Create triggers of CRMD_ORDERADM_H******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE TRIGGER $(schema).[/1LT/00000610INS] ON $(schema).[CRMD_ORDERADM_H] FOR INSERT AS set nocount on if exists (select * from inserted where CLIENT = '100' ) BEGIN INSERT INTO [/1CADMC/00000610]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,     [CLIENT],          [GUID],          'I'     FROM inserted END 
GO
 CREATE TRIGGER $(schema).[/1LT/00000610DEL]   ON $(schema).[CRMD_ORDERADM_H]   FOR DELETE   AS     set nocount on if exists (select * from deleted where CLIENT = '100' ) BEGIN INSERT INTO [/1CADMC/00000610]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],         'D'     FROM deleted END 
GO
 CREATE TRIGGER $(schema).[/1LT/00000610UPD1]   ON $(schema).[CRMD_ORDERADM_H]   FOR UPDATE   AS   BEGIN    set nocount on if exists (select * from inserted where CLIENT = '100' ) BEGIN     IF UPDATE([CLIENT]) OR     UPDATE([GUID])     BEGIN   INSERT INTO [/1CADMC/00000610]   SELECT CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],           'D'     FROM deleted   INSERT INTO [/1CADMC/00000610]   SELECT CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],           'I'     FROM inserted     END   ELSE BEGIN   INSERT INTO [/1CADMC/00000610]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],           'U'     FROM inserted    END   END END 
GO


