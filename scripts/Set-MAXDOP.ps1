[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [int]$MaxDegreeOfParallelism
)

$Query = @"
EXEC sp_configure 'show advanced options', 1
RECONFIGURE WITH OVERRIDE

EXEC sp_configure 'max degree of parallelism', $($MaxDegreeOfParallelism)
RECONFIGURE WITH OVERRIDE

EXEC sp_configure 'show advanced options', 0
RECONFIGURE WITH OVERRIDE
"@

Invoke-SqlCmd -Query $Query