-- exec sp_configure 'show advanced options', 1
-- reconfigure with override
-- exec sp_configure 'min server memory (MB)', 426000
-- exec sp_configure 'max server memory (MB)', 426000
-- reconfigure with override
-- exec sp_configure 'max degree of parallelism', 1
-- reconfigure with override
-- exec sp_configure 'xp_cmdshell', 1
-- reconfigure with override
-- exec sp_configure 'SMO and DMO XPs', 1
-- reconfigure with override

alter database $(database) set recovery full
alter database $(database) set auto_create_statistics on
alter database $(database) set auto_update_statistics on
alter database $(database) set auto_update_statistics_async on
alter database $(database) set page_verify checksum

USE master
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=6000, 
      @jobhistory_max_rows_per_job=500
GO
