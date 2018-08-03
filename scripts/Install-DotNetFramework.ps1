If ((Get-WindowsFeature Net-Framework).Installed -eq $false) {
    Add-WindowsFeature Net-Framework -IncludeAllSubFeature
}