@description('Location for all resources')
param location string = resourceGroup().location

@description('Prefix for naming all resources')
param prefix string = 'iac'

// VNet names and ranges
var hubVnetName       = '${prefix}-vnet-hub'
var spokeAppVnetName  = '${prefix}-vnet-spoke-app'
var spokeIdVnetName   = '${prefix}-vnet-spoke-id'
var spokeWebVnetName  = '${prefix}-vnet-spoke-web'
var spokeAvdVnetName  = '${prefix}-vnet-spoke-avd'

// VNet: HUB
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.40.0.0/16'
      ]
    }
    subnets: [
  {
    name: 'AzureFirewallSubnet'
    properties: {
      addressPrefix: '10.40.0.0/24'
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix: '10.40.1.0/26'
    }
  }
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: '10.40.1.64/26'
    }
  }
  {
    name: 'subnet-shared'
    properties: {
      addressPrefix: '10.40.1.128/26'
    }
  }
]
  }
}

// VNet: SPOKE - APP
resource spokeAppVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: spokeAppVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.41.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-default'
        properties: {
          addressPrefix: '10.41.0.0/24'
        }
      }
    ]
  }
}

// VNet: SPOKE - ID
resource spokeIdVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: spokeIdVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.42.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-default'
        properties: {
          addressPrefix: '10.42.0.0/24'
        }
      }
    ]
  }
}

// VNet: SPOKE - WEB
resource spokeWebVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: spokeWebVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.43.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-default'
        properties: {
          addressPrefix: '10.43.0.0/24'
        }
      }
    ]
  }
}

// VNet: SPOKE - AVD
resource spokeAvdVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: spokeAvdVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.44.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-default'
        properties: {
          addressPrefix: '10.44.0.0/24'
        }
      }
    ]
  }
}

//
// Peering: SPOKES to HUB
//

resource spokeAppToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${spokeAppVnetName}-to-${hubVnetName}'
  parent: spokeAppVnet
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

resource spokeIdToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${spokeIdVnetName}-to-${hubVnetName}'
  parent: spokeIdVnet
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

resource spokeWebToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${spokeWebVnetName}-to-${hubVnetName}'
  parent: spokeWebVnet
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

resource spokeAvdToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${spokeAvdVnetName}-to-${hubVnetName}'
  parent: spokeAvdVnet
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

//
// Peering: HUB to SPOKES
//

resource hubToSpokeApp 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${hubVnetName}-to-${spokeAppVnetName}'
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: spokeAppVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

resource hubToSpokeId 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${hubVnetName}-to-${spokeIdVnetName}'
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: spokeIdVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

resource hubToSpokeWeb 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${hubVnetName}-to-${spokeWebVnetName}'
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: spokeWebVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

resource hubToSpokeAvd 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${hubVnetName}-to-${spokeAvdVnetName}'
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: spokeAvdVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}
