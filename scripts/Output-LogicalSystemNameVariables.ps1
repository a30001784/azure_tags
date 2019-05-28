# Reads content from inputted file and outputs variables for use in future VSTS tasks
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]$VarsFile
)

try {
    $file = [IO.Path]::GetFileNameWithoutExtension($VarsFile)
    $count = 0

    foreach ($logsys in $(Get-Content $VarsFile)) {
        $count+=1
        $var_name = "LOGSYS_$($file)_$($count)"
        Write-Host "##vso[task.setvariable variable=$($var_name);isOutput=true]$($logsys)"
    }

} catch {
    Write-Error "Error occured:"
    Write-Error $_
    [Environment]::Exit(1)
}

