# Installs Windows Management Framework which provides PowerShell version 4.0

mkdir C:\install
mkdir C:\scripts

$date = (get-date).AddMinutes(5).ToString("HH:mm")

(New-Object Net.WebClient).DownloadFile("https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1", "C:\scripts\ConfigureRemotingForAnsible.ps1")
(New-Object Net.WebClient).DownloadFile("https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu", "C:\install\wmf4.msu")

& schtasks.exe /create /S localhost /RU SYSTEM /TN 'Configure Remoting For Ansible' /TR 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File C:\scripts\ConfigureRemotingForAnsible.ps1' /SC ONCE /ST $date
& C:\install\wmf4.msu /quiet

# Server will restart now...
