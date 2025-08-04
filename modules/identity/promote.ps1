param(
  [string]$DomainName,
  [string]$AdminUser,
  [string]$AdminPassword
)

$ErrorActionPreference = "Stop"

Install-WindowsFeature AD-Domain-Services

$secpasswd = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("$DomainName\$AdminUser", $secpasswd)

Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $secpasswd -InstallDns -Force

Restart-Computer -Force
