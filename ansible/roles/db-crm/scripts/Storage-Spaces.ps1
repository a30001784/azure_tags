[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [char]$DriveLetter,

    [Parameter(Mandatory=$true)]
    [int]$Interleave,

    [Parameter(Mandatory=$true)]
    [string]$FileSystemLabel,

    # Default is to pool all available disks
    [int]$NumDisks = (Get-PhysicalDisk -CanPool $true).Count
)

$ErrorActionPreference = "Stop"

$PhysicalDisks = Get-PhysicalDisk -CanPool $true | Select-Object -First $NumDisks

If ($PhysicalDisks.Count -eq 0) {
    Write-Host "[INFO] No disks available for pooling"
    Write-Host "Exiting..."
    [Environment]::Exit(0)
}

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