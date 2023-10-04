// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: ruleName
  scope: cluster
  properties: {
    dataCollectionRuleId: ruleId
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
  }
}

// ---------
// Resources
// ---------

resource cluster 'Microsoft.ContainerService/managedClusters@2023-07-02-preview' existing = {
  name: managedCluster.name
}

// ----------
// Parameters
// ----------

param managedCluster object
param ruleName string
param ruleId string
