param name string
param location string = resourceGroup().location
param tags object = {}

param customSubDomainName string = name
param kind string = 'OpenAI'
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'
param sku object = {
  name: 'S0'
}

param useOpenAiGpt4 bool = true
param openAiGpt4oDeploymentName string = ''

param openAiGpt4oDeployObj object = {
  name: openAiGpt4oDeploymentName
  model: {
    format: 'OpenAI'
    name: 'gpt-4o'
    version: '2024-05-13'
  }
  sku: {
    name: 'Standard'
    capacity: 8
  }
}

param deployments array = useOpenAiGpt4? [
  openAiGpt4oDeployObj
]: [
]

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
  sku: sku
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: account
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: deployment.?raiPolicyName ?? null
  }
  sku: deployment.?sku ?? {
    name: 'Standard'
    capacity: 20
  }
}]

output endpoint string = account.properties.endpoint
output id string = account.id
output name string = account.name
