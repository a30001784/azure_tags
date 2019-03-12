[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Source,

    [Parameter(Position=2)]
    [char]$DriveLetter='K'
)

$shares = "Archive","Interface"

# Copy folder structure only
foreach ($share in $shares) {
    Get-ChildItem -Path ("\\{0}\{1}" -f $Source, $share) -Recurse -Directory | `
        Where-Object { $_.FullName -inotmatch "scripts" } | `
            ForEach-Object {
                $newPath = ($_.FullName).Replace(("\\{0}" -f $Source),("{0}:" -f $DriveLetter))
                New-Item -Path $newPath -ItemType Directory
            }
    New-SmbShare -Name $share -Path ("{0}:\{1}" -f $DriveLetter,$share)
}

# Copy scripts directory
Get-ChildItem -Path ("\\{0}\Interface" -f $Source) -Filter "scripts" | `
    Copy-Item -Destination ("{0}:\Interface" -f $DriveLetter) -Recurse
