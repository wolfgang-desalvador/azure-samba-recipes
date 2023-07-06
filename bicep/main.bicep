// This script deploys all the OS Distro VMs for repo-testing.
// This is not needed in production, only for repository maintenance

@description('SubnetID where to attach the VMs')
param subnetId string

@secure()
@description('Admin password for the VMs')
param adminPassword string

param emptyObject object = {
  name: ''
  product: ''
  publisher: ''
}

param images object = {
    centos79: {
      imageReference: {
        publisher: 'OpenLogic'
        offer: 'CentOS'
        sku: '7_9-gen2'
        version: 'latest'
      }
      planReference:  emptyObject
    }
    redhat79:  {
        imageReference: {
          publisher: 'RedHat'
          offer: 'RHEL'
          sku: '79-gen2'
          version: 'latest'
      }
      planReference: emptyObject
    }
    redhat88: {
      imageReference: {
        publisher: 'RedHat'
        offer: 'RHEL'
        sku: '88-gen2'
        version: 'latest'
      }
      planReference:  emptyObject

  }
   ubuntu20: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      planReference:  emptyObject
  }
  ubuntu22: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
    }
    planReference: emptyObject
  }
    alma8: {
      imageReference: {
        publisher: 'almalinux'
        offer: 'almalinux'
        sku: '8_5-gen2'
        version: 'latest'
      }
      planReference: {
        name: '8_5-gen2'
        product: 'almalinux'
        publisher: 'almalinux'
      }
    }
}


module virtualMachineWinbind './vm.bicep' = [for virtualMachine in items(images): {
  name: '${virtualMachine.key}-winbind'
  params: {
    location: resourceGroup().location
    virtualMachineName: '${virtualMachine.key}-winbind'
    planReference: virtualMachine.value.planReference
    imageReference: virtualMachine.value.imageReference
    subnetId: subnetId
    adminPassword: adminPassword
  }   
}]

module virtualMachineStandalone './vm.bicep' = [for virtualMachine in items(images): {
  name: '${virtualMachine.key}-standalone'
  params: {
    location: resourceGroup().location
    virtualMachineName: '${virtualMachine.key}-standalone'
    planReference: virtualMachine.value.planReference
    imageReference: virtualMachine.value.imageReference
    subnetId: subnetId
    adminPassword: adminPassword
  }   
}]


module virtualMachineSSSD './vm.bicep' = [for virtualMachine in items(images): {
  name: '${virtualMachine.key}-sssd'
  params: {
    location: resourceGroup().location
    virtualMachineName: '${virtualMachine.key}-sssd'
    planReference: virtualMachine.value.planReference
    imageReference: virtualMachine.value.imageReference
    subnetId: subnetId
    adminPassword: adminPassword
  }   
}]
