[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [char]$DriveLetter,

    [Parameter(Mandatory=$true)]
    [int]$Interleave,

    [Parameter(Mandatory=$true)]
    [string]$FileSystemLabel
)

$ErrorActionPreference = "Stop"

$PhysicalDisks = Get-PhysicalDisk -CanPool $true

Try {
    New-StoragePool -FriendlyName $FileSystemLabel -StorageSubsystemFriendlyName "Storage Spaces*" -PhysicalDisks $PhysicalDisks | `
        New-VirtualDisk -FriendlyName $FileSystemLabel -Interleave $Interleave -NumberOfColumns $PhysicalDisks.Count -ResiliencySettingName simple -UseMaximumSize | `
        Initialize-Disk -PartitionStyle GPT -PassThru | `
        New-Partition -DriveLetter $DriveLetter -UseMaximumSize | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $FileSystemLabel -AllocationUnitSize 65536 -Confirm:$false
}
Catch {
    Write-Error "$($_.Exception.Message)"
    [Environment]::Exit(1)
}