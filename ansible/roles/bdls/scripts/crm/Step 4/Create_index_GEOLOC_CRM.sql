USE $(database)
GO

/****** Takes 10 mins ******/

/****** Create triggers in GEOLOC ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE TRIGGER $(schema).[/1LT/00001274DEL]   ON $(schema).[GEOLOC]   FOR DELETE   AS     set nocount on if exists (select * from deleted where CLIENT = '100' ) BEGIN INSERT INTO [/1CADMC/00001274]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUIDLOC],         'D'     FROM deleted END 
GO
 CREATE TRIGGER $(schema).[/1LT/00001274INS] ON $(schema).[GEOLOC] FOR INSERT AS set nocount on if exists (select * from inserted where CLIENT = '100' ) BEGIN INSERT INTO [/1CADMC/00001274]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,     [CLIENT],          [GUIDLOC],          'I'     FROM inserted END 
GO
CREATE TRIGGER $(schema).[/1LT/00001274UPD1]   ON $(schema).[GEOLOC]   FOR UPDATE   AS   BEGIN    set nocount on if exists (select * from inserted where CLIENT = '100' ) BEGIN     IF UPDATE([CLIENT]) OR     UPDATE([GUIDLOC])     BEGIN   INSERT INTO [/1CADMC/00001274]   SELECT CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUIDLOC],           'D'     FROM deleted   INSERT INTO [/1CADMC/00001274]   SELECT CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUIDLOC],           'I'     FROM inserted     END   ELSE BEGIN   INSERT INTO [/1CADMC/00001274]   SELECT  CONVERT(VARCHAR, GETUTCDATE(), 121), 0,      [CLIENT],          [GUIDLOC],           'U'     FROM inserted    END   END END 
GO



/****** GEOLOC index 3******/
CREATE NONCLUSTERED INDEX [GEOLOC~003] ON $(schema).[GEOLOC]
(
	[CLIENT] ASC,
	[ADDRGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** GEOLOC index 2******/
CREATE NONCLUSTERED INDEX [GEOLOC~002] ON $(schema).[GEOLOC]
(
	[CLIENT] ASC,
	[ADDRNUMBER] ASC,
	[ADDRLOGSYS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** GEOLOC index 1******/
CREATE NONCLUSTERED INDEX [GEOLOC~001] ON $(schema).[GEOLOC]
(
	[CLIENT] ASC,
	[LONGITUDE] ASC,
	[LATITUDE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


