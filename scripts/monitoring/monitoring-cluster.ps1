# Script PowerShell pour monitoring AKS via Azure CLI
# Cluster: K8workshopaks-restored

# Variables
$clusterName = "K8workshopaks-restored"
$resourceGroup = "aks-restored-rg"
$workspaceName = "law-secops-poc-francecentral"
$workspaceRG = "rg-secops-poc-francecentral"

Write-Host "🔍 MONITORING CLUSTER AKS: $clusterName" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# 1. État du cluster
Write-Host "`n📊 1. État du cluster:" -ForegroundColor Yellow
kubectl get nodes -o wide

# 2. État des pods MongoDB
Write-Host "`n🗄️ 2. État MongoDB:" -ForegroundColor Yellow
kubectl get pods --namespace ratingapp -o wide

# 3. Utilisation des ressources
Write-Host "`n📈 3. Utilisation des ressources:" -ForegroundColor Yellow
kubectl top nodes
kubectl top pods --namespace ratingapp

# 4. Événements récents
Write-Host "`n⚠️ 4. Événements récents:" -ForegroundColor Yellow
kubectl get events --sort-by='.lastTimestamp' | Select-Object -Last 10

# 5. Services exposés
Write-Host "`n🌐 5. Services:" -ForegroundColor Yellow
kubectl get services --namespace ratingapp

# 6. Requête Log Analytics simple (nécessite Azure CLI)
Write-Host "`n📊 6. Requête Log Analytics - Pods actifs:" -ForegroundColor Yellow
$query = @"
KubePodInventory
| where ClusterName == 'K8workshopaks-restored'
| where TimeGenerated > ago(1h)
| summarize count() by PodStatus, Namespace
| order by count_ desc
"@

try {
    az monitor log-analytics query --workspace $workspaceName --resource-group $workspaceRG --analytics-query $query --output table
} catch {
    Write-Host "Erreur lors de l'exécution de la requête Log Analytics" -ForegroundColor Red
}

Write-Host "`n✅ Monitoring terminé!" -ForegroundColor Green
Write-Host "`n🔗 Accès web:" -ForegroundColor Cyan
Write-Host "Container Insights: https://portal.azure.com/#@/resource/subscriptions/a56f5503-7af4-45e6-8f96-dd6c75a8883d/resourceGroups/aks-restored-rg/providers/Microsoft.ContainerService/managedClusters/K8workshopaks-restored/insights"
Write-Host "Log Analytics: https://portal.azure.com/#@/resource/subscriptions/a56f5503-7af4-45e6-8f96-dd6c75a8883d/resourceGroups/rg-secops-poc-francecentral/providers/Microsoft.OperationalInsights/workspaces/law-secops-poc-francecentral/Logs"