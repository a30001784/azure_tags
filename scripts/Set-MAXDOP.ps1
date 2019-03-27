[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [int]$MaxDegreeOfParallelism
)

$Query = @"
EXEC sp_configure 'max_degree of parallelism', $($MaxDegreeOfParallelism)
RECONFIGURE WITH OVERRIDE
"@

Invoke-SqlCmd -Query $Query