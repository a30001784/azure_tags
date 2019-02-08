[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [char]$DriveLetter
)

$Disks = Get-WmiObject Win32_DiskDrive -Filter "Partitions = 0"

If ( ($Disks | Measure-Object).Count -eq 0 ) {
    [Environment]::Exit(0)
}

Foreach ($disk in $Disks) { 
   $disk.DeviceID
   $disk.Index
   "select disk "+$disk.Index+"`r clean`r create partition primary`r format fs=ntfs unit=65536 quick`r active`r assign letter=$($DriveLetter)" | diskpart
}