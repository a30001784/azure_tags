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
        -QueryTimeout 0 `
        -AbortOnError

} catch { 
    Write-Host "Error occurred:"
    Write-Host $_
    [Environment]::Exit(1)
}
