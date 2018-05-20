# .\Format-Volume -DriveLetter F -FileSystemLabel Data
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

Try {
    Get-Disk -Number $DiskNumber | `
        Initialize-Disk -PartitionStyle GPT -PassThru | `
        New-Partition -DriveLetter $DriveLetter -UseMaximumSize

    Format-Volume -FileSystem NTFS -NewFileSystemLabel $FileSystemLabel -DriveLetter $DriveLetter -Confirm:$false
}
Catch {
    [Environment]::Exit(1)
}