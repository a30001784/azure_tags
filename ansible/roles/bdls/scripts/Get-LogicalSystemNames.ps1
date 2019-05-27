# Retrieves logical system names from SAP database and writes them to a file
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$Database,
    
    [Parameter(Mandatory=$true)]
    [string]$Schema,
    
    [Parameter(Mandatory=$false)]
    [string]$OutFile = "$($Database).txt"
)

try {
    $Patterns = @("B%", "M%", "X%", "AGLMDH%")

    if (Test-Path $OutFile) {
        Remove-Item $OutFile -Force
    }

    Add-Content $OutFile $(Invoke-Sqlcmd `
        -Database $Database `
        -Query "SELECT LOGSYS FROM $($schema).T000 WHERE MANDT = 100" `
        -IncludeSqlUserErrors `
        -AbortOnError).LOGSYS

    foreach ($pattern in $Patterns) {
        Add-Content $OutFile $(Invoke-Sqlcmd `
            -Database $Database `
            -Query "SELECT PARNUM from ia5.EDPP1 where PARNUM LIKE '$($pattern)%'" `
            -IncludeSqlUserErrors `
            -AbortOnError).PARNUM            
    }
}
catch {
    Write-Error "Error occured:"
    Write-Error $_
    [Environment]::Exit(1)
}