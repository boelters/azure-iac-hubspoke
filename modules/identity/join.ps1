param(
  [string]$DomainName,
  [string]$AdminUser,
  [string]$AdminPassword,
  [string]$DcName
)

$ErrorActionPreference = "Stop"

Install-WindowsFeature AD-Domain-Services

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

$secpasswd = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("$DomainName\$AdminUser", $secpasswd)

Add-Computer -DomainName $DomainName -Credential $cred -Restart
