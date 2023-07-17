param clusterName string
param location string = resourceGroup().location

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: clusterName
  location: location
  tags: {}
  properties: {
    kubernetesVersion: '1.20.7'
    enableRBAC: true
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'agentpool1'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osDiskSizeGB: 30
        osType: 'Linux'
        maxPods: 110
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    servicePrincipalProfile: {
      clientId: '<Your SPN Client ID>'
      secret: '<Your SPN Client Secret>'
    }
  }
}

output clusterNameOutput string = aksCluster.name
output kubeConfigOutput string = aksCluster.properties.kubeConfig
