USE master
GO

--Disconnect all existing session.
ALTER DATABASE $(database) SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

--Change database in to OFFLINE mode.
ALTER DATABASE $(database) SET OFFLINE
GO

--Change database in to ONLINE mode.
ALTER DATABASE $(database) SET ONLINE
GO

--Restore Multi User Mode
ALTER DATABASE $(database) SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO

Declare @Path nvarchar(max)
Declare @Sql nvarchar(max)
Declare @oldfile nvarchar(max)
Declare @newfile nvarchar(max)
DECLARE @i INT = 1, @maxi INT 
DECLARE @j INT = 0, @maxj INT 
DECLARE @k INT = 0, @maxk INT 
DECLARE @l INT = 0, @maxl INT 
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
WHERE database_id = DB_ID(N'$(database)') AND name LIKE '%DATA1'

--Store .ndf data file names in Table variable	
INSERT INTO @olddatafilenames
SELECT 
name AS [Logical Name]
FROM sys.master_files
WHERE database_id = DB_ID(N'$(database)') AND name NOT LIKE '%LOG%' AND name NOT LIKE '%DATA1'

--Store Log file names in Table variable	
INSERT INTO @oldlogfilenames
SELECT 
name AS [Logical Name]
FROM sys.master_files
WHERE database_id = DB_ID(N'$(database)') AND name LIKE '%LOG%' 

--Modify Secondary .ndf Data File names and Path (2-8)
SELECT * FROM @olddatafilenames
SELECT @maxi = MAX(RowID) FROM @olddatafilenames
WHILE @i <= (@maxi-8)
BEGIN 
		SET @oldfile  =  (SELECT LogicalName FROM @olddatafilenames WHERE RowID= (@i))
		Set @newfile = '$(database)DATA' + CAST((@i+1) AS VARCHAR(10))
		Set @Path = '''I:\$(database)\$(database)DATA'+CAST((@i+1) AS VARCHAR(10))+'\'+@newfile+'.ndf'''
		Set @Sql = 'ALTER DATABASE  $(database) MODIFY FILE (Name='+@oldfile+',NEWNAME='+@newfile+',FileName='+@Path+')'
		Exec( @Sql );
		SET @i= @i + 1
END

--Modify Secondary .ndf Data File names and Path (2-8)
SELECT @maxi = MAX(RowID) FROM @olddatafilenames
WHILE @l <= (@maxi-8)
BEGIN 
		SET @oldfile  =  (SELECT LogicalName FROM @olddatafilenames WHERE RowID= (@i))
		Set @newfile = '$(database)DATA' + CAST((@i+1) AS VARCHAR(10))
		Set @Path = '''I:\$(database)\$(database)DATA'+CAST((@l+1) AS VARCHAR(10))+'\'+@newfile+'.ndf'''
		Set @Sql = 'ALTER DATABASE  $(database) MODIFY FILE (Name='+@oldfile+',NEWNAME='+@newfile+',FileName='+@Path+')'
		Exec( @Sql );
		SET @i= @i + 1
		SET @l= @l + 1
END

--Modify Log File names and Path
SELECT * FROM @oldlogfilenames
SELECT @maxj = MAX(RowID) FROM @oldlogfilenames
WHILE @j < @maxj
BEGIN 
		SET @oldfile  =  (SELECT LogicalName FROM @oldlogfilenames WHERE RowID= (@j+1))
		Set @newfile = '$(database)LOG' + CAST((@j+1) AS VARCHAR(10))
		Set @Path = 'I:\$(database)\$(database)LOG\'+@newfile+'.ldf'
		Set @Sql = 'ALTER DATABASE  $(database) MODIFY FILE (Name='+@oldfile+',NEWNAME='+@newfile+',FileName='''+@Path+''')'
		Exec( @Sql );
		SET @j= @j + 1
END

--Modify Primary Data File names and Path .mdf
SELECT * FROM @dbfilenames
SELECT @maxk = MAX(RowID) FROM @dbfilenames
WHILE @k < @maxk
BEGIN 
		SET @oldfile  =  (SELECT LogicalName FROM @dbfilenames WHERE RowID= (@k+1))
		Set @newfile = '$(database)DATA' + CAST((@k+1) AS VARCHAR(10))
		Set @Path = '''I:\$(database)\$(database)DATA'+CAST((@k+1) AS VARCHAR(10))+'\'+@newfile+'.mdf'''
		Set @Sql = 'ALTER DATABASE  $(database) MODIFY FILE (Name='+@oldfile+',NEWNAME='+@newfile+',FileName='+@Path+')'
		Exec( @Sql );
		SET @k= @k + 1
END