# Retrieves logical system names from SAP database and writes them to a file
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$Database,
    
    [Parameter(Mandatory=$true)]
    [string]$Schema,

    [Parameter(Mandatory=$true)]
    [string]$OutFile = "C:\Windows\Temp\$($Database).txt"
)

try {
    $LogicalSystemNames = ""
    $Patterns = @("B%", "M%", "X%", "AGLMDH%")

    if (Test-Path $OutFile) {
        Remove-Item $OutFile -Force
    }

    $LogicalSystemNames+=$(Invoke-Sqlcmd `
        -Database $Database `
        -Query "SELECT LOGSYS FROM $($schema).T000 WHERE MANDT = 100" `
        -IncludeSqlUserErrors `
        -AbortOnError).LOGSYS

    foreach ($pattern in $Patterns) {
        $LogicalSystemNames+=$(Invoke-Sqlcmd `
            -Database $Database `
            -Query "SELECT PARNUM from $($schema).EDPP1 where PARNUM LIKE '$($pattern)%'" `
            -IncludeSqlUserErrors `
            -AbortOnError).PARNUM            
    }

    Add-Content $OutFile $LogicalSystemNames
}
catch {
    Add-Content "C:\Windows\Temp\error.log" "Error occured:"
    Add-Content "C:\Windows\Temp\error.log" $_
    [Environment]::Exit(1)
}