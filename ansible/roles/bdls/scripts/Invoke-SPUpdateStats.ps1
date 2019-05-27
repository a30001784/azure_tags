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
        -AbortOnError

} catch { 
    Write-Error "Error occurred:"
    Write-Error $sqlerr
    [Environment]::Exit(1)
}
