USE tempdb
GO

Declare @Path nvarchar(max)
Declare @Sql nvarchar(max)
Declare @oldfile nvarchar(max)
Declare @newfile nvarchar(max)
DECLARE @i INT = 0, @maxi INT 
DECLARE @j INT = 0, @maxj INT 
DECLARE @k INT = 0, @maxk INT 
DECLARE @olddatafilenames TABLE (
    RowID INT IDENTITY
    ,LogicalName VARCHAR(20)
    )
DECLARE @oldlogfilenames TABLE (
    RowID INT IDENTITY
    ,LogicalName VARCHAR(20)
    )
DECLARE @dbfilenames TABLE (
    RowID INT IDENTITY
    ,LogicalName VARCHAR(20)
    )

--Store primary .mdf data file names in Table variable
INSERT INTO @dbfilenames
SELECT 
name AS [Logical Name]
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb') AND name NOT LIKE '%log%'

--Store Log file names in Table variable	
INSERT INTO @oldlogfilenames
SELECT 
name AS [Logical Name]
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb') AND name LIKE '%log%' 

--Modify Log File names and Path
SELECT * FROM @oldlogfilenames
SELECT @maxj = MAX(RowID) FROM @oldlogfilenames
WHILE @j < @maxj
BEGIN 
		SET @oldfile  =  (SELECT LogicalName FROM @oldlogfilenames WHERE RowID= (@j+1))
		Set @newfile = 'templog'
		Set @Path = 'I:\$(database)\$(database)LOG\'+@newfile+'.ldf'
		Set @Sql = 'ALTER DATABASE tempdb MODIFY FILE (Name='+@oldfile+',FileName='''+@Path+''')'
		Exec( @Sql );
		SET @j= @j + 1
END

--Modify Primary Data File names and Path .mdf
SELECT * FROM @dbfilenames
SELECT @maxk = MAX(RowID) FROM @dbfilenames
WHILE @k < @maxk
BEGIN 
		SET @oldfile  =  (SELECT LogicalName FROM @dbfilenames WHERE RowID= (@k+1))
		Set @newfile = 'tempdata' + CAST((@k+1) AS VARCHAR(10))
		Set @Path = '''I:\$(database)\$(database)DATA'+CAST((@k+1) AS VARCHAR(10))+'\'+@newfile+'.mdf'''
		Set @Sql = 'ALTER DATABASE tempdb MODIFY FILE (Name='+@oldfile+',NEWNAME='+@newfile+',FileName='+@Path+')'
		Exec( @Sql );
		SET @k= @k + 1
END

ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdata2', FILENAME = N'I:\$(database)\$(database)DATA2\tempdata2.ndf' , SIZE = 5242880KB , FILEGROWTH = 1048576KB ) 
GO 
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdata3', FILENAME = N'I:\$(database)\$(database)DATA3\tempdata3.ndf' , SIZE = 5242880KB , FILEGROWTH = 1048576KB ) 
GO 
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdata4', FILENAME = N'I:\$(database)\$(database)DATA4\tempdata4.ndf' , SIZE = 5242880KB , FILEGROWTH = 1048576KB ) 
GO 
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdata5', FILENAME = N'I:\$(database)\$(database)DATA5\tempdata5.ndf' , SIZE = 5242880KB , FILEGROWTH = 1048576KB ) 
GO 
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdata6', FILENAME = N'I:\$(database)\$(database)DATA6\tempdata6.ndf' , SIZE = 5242880KB , FILEGROWTH = 1048576KB ) 
GO 
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdata7', FILENAME = N'I:\$(database)\$(database)DATA7\tempdata7.ndf' , SIZE = 5242880KB , FILEGROWTH = 1048576KB ) 
GO 
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdata8', FILENAME = N'I:\$(database)\$(database)DATA8\tempdata8.ndf' , SIZE = 5242880KB , FILEGROWTH = 1048576KB ) 
GO 
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdata1', SIZE = 5242880KB )
GO