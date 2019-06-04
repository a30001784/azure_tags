[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [char]$DriveLetter,

    [Parameter(Mandatory = $false)]
    [int]$Interleave = 65536,

    [Parameter(Mandatory = $true)]
    [string]$FileSystemLabel,

    # Default is to pool all available disks.
    [Parameter(Mandatory = $false)]
    [int]$NumDisks = ((Get-PhysicalDisk | Where-Object { [int]$_.DeviceId -ge 2 -and $_.CanPool -eq $true }).Count)
)

$ErrorActionPreference = "Stop"

$StorageSubsystemFriendlyName = switch ((Get-WmiObject Win32_OperatingSystem).Caption) {
    "Microsoft Windows Server 2016 Datacenter" { "Windows Storage*" }
    "Microsoft Windows Server 2012 R2 Datacenter" { "Storage Spaces*" }
}

# Get eligible physical disks for pooling. 
$PoolablePhysicalDisks = Get-PhysicalDisk | `
    Where-Object { [int]$_.DeviceId -ge 2 -and $_.CanPool -eq $true } | `
        Select-Object -First $NumDisks

# No disks to pool. Exit without error.
If ($PoolablePhysicalDisks.Count -eq 0) {
    Write-Host "[INFO] No disks available for pooling"
    Write-Host "Exiting..."
    [Environment]::Exit(0)
}

Try {
    # Get number of non-primordial storage pools.
    $NumStoragePools = ((Get-StoragePool -IsPrimordial $false -ErrorAction SilentlyContinue | Measure-Object).Count)

    # Create striped storage pool and volume from eligible physical disks.
    New-StoragePool -FriendlyName "StoragePool_$($NumStoragePools+1)" -StorageSubsystemFriendlyName $StorageSubsystemFriendlyName -PhysicalDisks $PoolablePhysicalDisks | `
        New-VirtualDisk -FriendlyName $FileSystemLabel -Interleave $Interleave -NumberOfColumns $PoolablePhysicalDisks.Count -ResiliencySettingName simple -UseMaximumSize | `
            Initialize-Disk -PartitionStyle GPT -PassThru | `
                New-Partition -DriveLetter $DriveLetter -UseMaximumSize | `
                    Format-Volume -FileSystem NTFS -NewFileSystemLabel $FileSystemLabel -AllocationUnitSize 65536 -Confirm:$false
}
Catch {
    Write-Error "$($_.Exception.Message)"
    [Environment]::Exit(1)
}