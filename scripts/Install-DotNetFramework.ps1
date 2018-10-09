$DotNetFramework = switch ((Get-WmiObject Win32_OperatingSystem).Caption) {
    "Microsoft Windows Server 2008 R2 Datacenter " { "NET-Framework" }
    "Microsoft Windows Server 2012 R2 Datacenter" { "NET-Framework-Features" }
}

If ((Get-WindowsFeature $DotNetFramework).Installed -eq $false) {
    Add-WindowsFeature $DotNetFramework -IncludeAllSubFeature
}