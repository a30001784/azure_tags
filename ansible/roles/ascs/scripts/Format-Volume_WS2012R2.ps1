# .\Format-Volume -DiskNumber 2 -DriveLetter F -FileSystemLabel Data
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [int]$DiskNumber,
    
    [Parameter(Mandatory=$true)]
    [char]$DriveLetter,

    [Parameter(Mandatory=$true)]
    [string]$FileSystemLabel
)

$ErrorActionPreference = "Stop"

If ( (Get-Disk -Number $DiskNumber).PartitionStyle -eq "GPT" ) {
    Write-Host "[INFO] Disk number `"$DiskNumber`" is already formatted."
    Write-Host "Exiting..."
    [Environment]::Exit(0)
}

Try {
    Get-Disk -Number $DiskNumber | `
        Initialize-Disk -PartitionStyle GPT -PassThru | `
        New-Partition -DriveLetter $DriveLetter -UseMaximumSize

    Format-Volume -FileSystem NTFS -NewFileSystemLabel $FileSystemLabel -DriveLetter $DriveLetter -Confirm:$false
}
Catch {
    Write-Error "$($_.Exception.Message)"
    [Environment]::Exit(1)
}