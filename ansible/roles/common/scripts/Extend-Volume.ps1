[CmdletBinding()]
Param
(
    # Defaults to C drive if DriveLetter is not specified
    [Parameter(Mandatory=$false)]
    [char]$DriveLetter = 'C'
)

Try {
    # Get current partition size
    $CurrentSize = (Get-Partition -DriveLetter $DriveLetter).Size

    # Get max size of partition
    $MaxSize = (Get-PartitionSupportedSize -DriveLetter $DriveLetter).SizeMax

    If ($CurrentSize -lt $MaxSize) {
        # Extend volume to maximum capacity
        Resize-Partition -DriveLetter $DriveLetter -Size $MaxSize
    }
    Else {
        Write-Host "Volume `"$DriveLetter`" already at maximum capacity"
        Write-Host "Exiting..."
        [Environment]::Exit(0)
    }
}
Catch {
    Write-Error "$($_.Exception.Message)"
    [Environment]::Exit(1)
}