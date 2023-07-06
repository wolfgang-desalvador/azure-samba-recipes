param virtualMachineName string

@secure()
param adminPassword string

param location string
param subnetId string
param imageReference object
param planReference object

param osDiskSize int = 64
param adminUser string = 'azureuser'
param nicName string = '${virtualMachineName}-nic'
param dataDisks array = []


module nic 'nic.bicep' = {
  name: '${virtualMachineName}-nic-deployment'
  params: {
    nicName: nicName
    subnetId: subnetId
    location: location
  }
}

resource networkCard 'Microsoft.Network/networkInterfaces@2022-07-01' existing = {
  name: nicName
  scope: resourceGroup()
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: virtualMachineName
  location: location
  dependsOn: [nic]
  identity: {
    type: 'SystemAssigned'
  }
  plan: (planReference.name == '' ? null : planReference)
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2ads_v5'
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSize
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      dataDisks: dataDisks
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUser
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkCard.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output vm object = virtualMachine
