param location string
param nicName string
param subnetId string

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    enableAcceleratedNetworking: true
    enableIPForwarding: false
  }
}

output nicId string = nic.id
