[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$Database
)

try {
    Invoke-Sqlcmd `
        -Database $Database `
        -Query "EXEC sp_updatestats" `
        -IncludeSqlUserErrors `
        -AbortOnError
} catch { 
    Write-Error "Error occured:"
    Write-Error $_
    [Environment]::Exit(1)
}
