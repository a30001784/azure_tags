[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$SID,

    [Parameter(Mandatory=$false)]
    [int]$Retries=10,

    [Parameter(Mandatory=$false)]
    [int]$RetryInterval=60
)

$attempts = 0

Do {
    if ($attempts -gt $Retries) {
        Write-Host "Retry count exceeded. Exiting..."
        [Environment]::Exit(1)
    }

    Write-Host "Sleeping for $RetryInterval seconds..."
    Start-Sleep $RetryInterval
    $attempts++

} Until (Get-Content "C:\usr\sap\$SID\SUM\sdt\htdoc\ProcessOverview.xml" -ErrorAction SilentlyContinue | Select-String -Quiet -Pattern "<tool-status>SUCCESS</tool-status>")

Write-Host "Update process completed successfully"

