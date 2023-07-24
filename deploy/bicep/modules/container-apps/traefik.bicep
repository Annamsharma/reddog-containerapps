param containerAppsEnvName string
param location string
param workloadProfileName string

param minReplicas int = 0

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: containerAppsEnvName
}

resource traefik 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: 'reddog'
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    workloadProfileName: workloadProfileName
    template: {
      containers: [
        {
          name: 'traefik'
          image: 'ghcr.io/azure/reddog-retail-demo/reddog-traefik:latest'
          probes: [
            {
              type: 'startup'
              httpGet: {
                path: '/ping'
                port: 80
              }
              failureThreshold: 3
              initialDelaySeconds: 10
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 2
            }
            {
              type: 'liveness'
              httpGet: {
                path: '/ping'
                port: 80
              }
              failureThreshold: 3
              initialDelaySeconds: 10
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 2
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
      }
    }
    configuration: {
      dapr: {
        enabled: true
        appId: 'traefik'
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 80
      }
    }
  }
}

output subdomain string = traefik.name
