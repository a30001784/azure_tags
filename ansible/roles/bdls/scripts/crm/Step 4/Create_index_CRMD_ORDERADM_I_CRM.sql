USE $(database)
GO

/****** Takes 1 miniute******/

/****** Create triggers fro CRMD_ORDERADM_I ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE TRIGGER $(schema).[/1LT/00000785DEL]   ON $(schema).[CRMD_ORDERADM_I]   FOR DELETE   AS     set nocount on if exists (select * from deleted where CLIENT = '100' ) BEGIN INSERT INTO [/1CADMC/00000785]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],         'D'     FROM deleted END 
GO
 CREATE TRIGGER $(schema).[/1LT/00000785INS] ON $(schema).[CRMD_ORDERADM_I] FOR INSERT AS set nocount on if exists (select * from inserted where CLIENT = '100' ) BEGIN INSERT INTO [/1CADMC/00000785]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,     [CLIENT],          [GUID],          'I'     FROM inserted END 
GO
CREATE TRIGGER $(schema).[/1LT/00000785UPD1]   ON $(schema).[CRMD_ORDERADM_I]   FOR UPDATE   AS   BEGIN    set nocount on if exists (select * from inserted where CLIENT = '100' ) BEGIN     IF UPDATE([CLIENT]) OR     UPDATE([GUID])     BEGIN   INSERT INTO [/1CADMC/00000785]   SELECT CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],           'D'     FROM deleted   INSERT INTO [/1CADMC/00000785]   SELECT CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],           'I'     FROM inserted     END   ELSE BEGIN   INSERT INTO [/1CADMC/00000785]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUID],           'U'     FROM inserted    END   END END 
GO
