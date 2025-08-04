param(
    [string]$DomainName,
    [string]$AdminUser,
    [string]$AdminPassword,
    [string]$DcName
)

$ErrorActionPreference = "Stop"

# Install AD DS Role
Install-WindowsFeature AD-Domain-Services

# Wait until the first DC is reachable
$maxRetries = 18
$retryInterval = 10
for ($i = 0; $i -lt $maxRetries; $i++) {
    try {
        if (-not (Test-Connection -ComputerName $DcName -Count 1 -Quiet)) { throw }
        $dnsCheck = [System.Net.Dns]::GetHostEntry($DomainName)
        if (-not $dnsCheck) { throw }
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($DcName, 389)
        if (-not $tcpClient.Connected) { throw }
        break
    } catch {
        Start-Sleep -Seconds $retryInterval
    }
}

# Prepare credentials
$secpasswd = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("$DomainName\$AdminUser", $secpasswd)

# Join the domain
Add-Computer -DomainName $DomainName -Credential $cred -Force -Restart:$false

# Restart before promotion
Restart-Computer -Force

# Wait for reboot to complete
Start-Sleep -Seconds 60

# Promote to domain controller
Install-ADDSDomainController `
    -DomainName $DomainName `
    -Credential $cred `
    -SafeModeAdministratorPassword $secpasswd `
    -InstallDns `
    -Force
