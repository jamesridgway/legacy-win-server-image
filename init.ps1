$ErrorActionPreference = "stop"
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
$WebClient = New-Object System.Net.WebClient

# Install OpenSSH
Write-Host "SSH: Installing..."
Invoke-WebRequest -Uri "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip" -OutFile "C:\OpenSSH-Win64.zip"
Unzip "C:\OpenSSH-Win64.zip" "C:\OpenSSH-Win64\OpenSSH"
Move-Item -Path "C:\OpenSSH-Win64\OpenSSH\*" -Destination "C:\Program Files\OpenSSH"
Set-Location -Path "C:\Program Files\OpenSSH"
powershell -File .\install-sshd.ps1
.\ssh-keygen.exe -A
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Move-Item -Path "C:\\Users\\Administrator\\sshd_config" -Destination "C:\\ProgramData\\ssh\\sshd_config" -Force
Write-Host "SSH: Installed"

# Install IIS
Write-Host "IIS: Installing..."
Install-WindowsFeature -Name Web-Server, Web-Mgmt-Tools
Write-Host "IIS: Installed."

# Install .Net 3.1
Write-Host "Hosting Bundle: Installing..."
$WebClient.DownloadFile("https://download.visualstudio.microsoft.com/download/pr/fa3f472e-f47f-4ef5-8242-d3438dd59b42/9b2d9d4eecb33fe98060fd2a2cb01dcd/dotnet-hosting-3.1.0-win.exe","C:\dotnet-hosting-3.1.0-win.exe")
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/quiet")
$args.Add("/norestart")
Start-Process -FilePath "C:\dotnet-hosting-3.1.0-win.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru
New-WebSite -Name "Default Web Site" -Port 80 -HostHeader mywebsite.com -PhysicalPath "C:\inetpub\wwwroot\" -Force
Write-Host "Hosting Bundle: Installed"

# Install SQL Server Express 2012
Write-Host "SQL Server Express 2012: Installing"
$WebClient.DownloadFile("https://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLEXPRADV_x64_ENU.exe", "C:\SQLEXPRADV_x64_ENU.exe")
(Get-Content "C:\SqlConfigurationFile.ini").replace('WIN-HOSTNAME', [System.Net.Dns]::GetHostName()) | Set-Content "C:\SqlConfigurationFile.ini"
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/ConfigurationFile=""C:\SqlConfigurationFile.ini""")
Start-Process -FilePath "C:\SQLEXPRADV_x64_ENU.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru
Write-Host "SQL Server Express 2012: Installed"

# Set admin password
Write-Host "Admin password: setting"
net user Administrator $Env:ADMIN_PASSWORD
Write-Host "init.ps1 completed!"
