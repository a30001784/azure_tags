USE $(database)
GO

/****** Delete triggers CRMD_ORDERADM_H******/
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000610UPD1')
	DROP TRIGGER $(schema).[/1LT/00000610UPD1]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000610INS')
	DROP TRIGGER $(schema).[/1LT/00000610INS]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000610DEL')
	DROP TRIGGER $(schema).[/1LT/00000610DEL]
GO

/****** Delete triggers CRMD_ORDERADM_I******/
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000785INS')
	DROP TRIGGER $(schema).[/1LT/00000785INS]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000785UPD1')
	DROP TRIGGER $(schema).[/1LT/00000785UPD1]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000785DEL')
	DROP TRIGGER $(schema).[/1LT/00000785DEL]
GO

/****** Delete triggers GEOLOC ******/
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00001274DEL')
	DROP TRIGGER $(schema).[/1LT/00001274DEL]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00001274INS')
	DROP TRIGGER $(schema).[/1LT/00001274INS]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00001274UPD1')
	DROP TRIGGER $(schema).[/1LT/00001274UPD1]
GO

/****** Delete indexes GEOLOC ******/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'GEOLOC~001')
	DROP INDEX [GEOLOC~001] ON $(schema).[GEOLOC]
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'GEOLOC~002')
	DROP INDEX [GEOLOC~002] ON $(schema).[GEOLOC]
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'GEOLOC~003')
	DROP INDEX [GEOLOC~003] ON $(schema).[GEOLOC]
GO

/****** Delete indexes GEOOBJR ******/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'GEOOBJR~002')
	DROP INDEX [GEOOBJR~002] ON $(schema).[GEOOBJR]
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'GEOOBJR~003')
	DROP INDEX [GEOOBJR~003] ON $(schema).[GEOOBJR]
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'GEOOBJR~004')
	DROP INDEX [GEOOBJR~004] ON $(schema).[GEOOBJR]
GO


/****** Delete triggers COMM_PRODUCT ******/
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000775DEL')
	DROP TRIGGER $(schema).[/1LT/00000775DEL]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000775INS')
	DROP TRIGGER $(schema).[/1LT/00000775INS]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000775UPD1')
	DROP TRIGGER $(schema).[/1LT/00000775UPD1]
GO

/****** Delete indexes for COMM_PRODUCT ******/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'COMM_PRODUCT~ID')
	DROP INDEX [COMM_PRODUCT~ID] ON $(schema).[COMM_PRODUCT]
GO

/****** Delete index SRRELROLES ******/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'SRRELROLES~003')
	DROP INDEX [SRRELROLES~003] ON $(schema).[SRRELROLES]
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'SRRELROLES~001')
	DROP INDEX [SRRELROLES~001] ON $(schema).[SRRELROLES]
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'SRRELROLES~002')
	DROP INDEX [SRRELROLES~002] ON $(schema).[SRRELROLES]
GO

/****** Delete trigger of CRMD_BRELVONAI ******/

IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000499DEL')
	DROP TRIGGER $(schema).[/1LT/00000499DEL]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000499INS')
	DROP TRIGGER $(schema).[/1LT/00000499INS]
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = '/1LT/00000499UPD1')
	DROP TRIGGER $(schema).[/1LT/00000499UPD1]
GO
