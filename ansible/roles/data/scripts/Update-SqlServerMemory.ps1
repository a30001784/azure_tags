# Get installed RAM
$InstalledRam = Get-WmiObject -Class Win32_ComputerSystem

# Calculate 90% of available memory in MB
$SqlServerRam = [Math]::Round(($InstalledRam.TotalPhysicalMemory/ 1MB),2) * .9

# Configure SQL server max memory
$UpdateServerMaxMemory = @"
EXEC sp_configure 'show advanced options', 1
RECONFIGURE WITH OVERRIDE

EXEC sp_configure 'min server memory (MB)', $($SqlServerRam)
EXEC sp_configure 'max server memory (MB)', $($SqlServerRam)
RECONFIGURE WITH OVERRIDE

EXEC sp_configure 'show advanced options', 0
RECONFIGURE WITH OVERRIDE
"@

Invoke-Sqlcmd -Query $UpdateServerMaxMemory