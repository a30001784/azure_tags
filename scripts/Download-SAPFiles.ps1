[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory=$true)]
    [string]
    $StorageAccountKey,

    [Parameter(Mandatory=$true)]
    [string]
    $FileShareUri
)

$ErrorActionPreference = "Stop"

$FileShareUri = "\\aaasapautomationsa.file.core.windows.net\sapptia"

$Key = ConvertTo-SecureString -String $StorageAccountKey -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$($StorageAccountName)", $Key
New-PSDrive -Name X -PSProvider FileSystem -Root $FileShareUri -Credential $Credentials

foreach ($folder in ("DownloadStack","SAPCAR","SWPM10-SP23") ) {

   Copy-Item -Path "X:\installfiles\$folder" -Destination "C:\Install\." -Recurse -Force

}

Move-Item -Path "C:\Install\DownloadStack\IGS749-05\*" -Destination "C:\Install\DownloadStack\." -Force