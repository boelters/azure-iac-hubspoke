param location string
param prefix string
param adminUsername string
@secure()
param adminPassword string
param domainName string

var vnetName = '${prefix}-vnet-id'
var subnetName = 'default-subnet'
var nic1Name = '${prefix}-dc1-nic'
var nic2Name = '${prefix}-dc2-nic'
var dc1Ip = '10.41.0.4'
var dc2Ip = '10.41.0.5'

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: subnetName
}

resource dc1Nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: nic1Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: dc1Ip
          subnet: { id: subnet.id }
          primary: true
        }
      }
    ]
  }
}

resource dc2Nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: nic2Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: dc2Ip
          subnet: { id: subnet.id }
          primary: true
        }
      }
    ]
    dnsSettings: { dnsServers: [ dc1Ip ] }
  }
}

resource dc1 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: '${prefix}-dc1'
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B2ms' }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
    osProfile: {
      computerName: '${prefix}-dc1'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: { networkInterfaces: [{ id: dc1Nic.id }] }
  }
}

resource dc2 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: '${prefix}-dc2'
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B2ms' }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
    osProfile: {
      computerName: '${prefix}-dc2'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: { networkInterfaces: [{ id: dc2Nic.id }] }
  }
}

resource dc1Extension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: 'promote'
  parent: dc1
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: [ 'https://raw.githubusercontent.com/boelters/azure-iac-hubspoke/main/modules/identity/promote.ps1' ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File promote.ps1 -DomainName ${domainName} -AdminUser ${adminUsername} -AdminPassword ${adminPassword}'
    }
  }
}

resource dc2Extension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: 'join'
  parent: dc2
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: [ 'https://raw.githubusercontent.com/boelters/azure-iac-hubspoke/main/modules/identity/join.ps1' ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File join.ps1 -DomainName ${domainName} -AdminUser ${adminUsername} -AdminPassword ${adminPassword} -DcName ${prefix}-dc1'
    }
  }
}
