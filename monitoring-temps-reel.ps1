# ============================================
# MONITORING EN TEMPS RÉEL - CLUSTER AKS
# ============================================
# En attendant que Log Analytics collecte les données

Write-Host "🚀 MONITORING CLUSTER AKS - TEMPS RÉEL" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# 1. État général du cluster
Write-Host "`n📊 1. ÉTAT DU CLUSTER:" -ForegroundColor Yellow
Write-Host "Nodes:" -ForegroundColor Cyan
kubectl get nodes -o wide

Write-Host "`nNode Pools:" -ForegroundColor Cyan
az aks nodepool list --resource-group aks-restored-rg --cluster-name K8workshopaks-restored --output table

# 2. Utilisation des ressources
Write-Host "`n📈 2. UTILISATION DES RESSOURCES:" -ForegroundColor Yellow
Write-Host "CPU/Mémoire par node:" -ForegroundColor Cyan
kubectl top nodes

Write-Host "`nTous les pods par namespace:" -ForegroundColor Cyan
kubectl top pods --all-namespaces

# 3. État MongoDB
Write-Host "`n🗄️ 3. ÉTAT MONGODB:" -ForegroundColor Yellow
Write-Host "Pods MongoDB:" -ForegroundColor Cyan
kubectl get pods --namespace ratingapp -o wide

Write-Host "`nServices MongoDB:" -ForegroundColor Cyan
kubectl get services --namespace ratingapp

Write-Host "`nUtilisation ressources MongoDB:" -ForegroundColor Cyan
kubectl top pods --namespace ratingapp

# 4. Logs MongoDB récents
Write-Host "`n📝 4. LOGS MONGODB (dernières 20 lignes):" -ForegroundColor Yellow
kubectl logs --namespace ratingapp ratings-mongodb-77b48c69c6-b52rs --tail=20

# 5. Événements récents
Write-Host "`n⚠️ 5. ÉVÉNEMENTS RÉCENTS:" -ForegroundColor Yellow
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | Select-Object -Last 15

# 6. État des agents de monitoring
Write-Host "`n🔍 6. AGENTS DE MONITORING:" -ForegroundColor Yellow
Write-Host "Agents ama-logs:" -ForegroundColor Cyan
kubectl get pods --namespace kube-system | Select-String "ama-logs"

Write-Host "`nAgents ama-metrics:" -ForegroundColor Cyan
kubectl get pods --namespace kube-system | Select-String "ama-metrics"

# 7. Test connectivité MongoDB
Write-Host "`n🧪 7. TEST CONNECTIVITÉ MONGODB:" -ForegroundColor Yellow
$mongoService = kubectl get service ratings-mongodb --namespace ratingapp -o jsonpath='{.spec.clusterIP}'
Write-Host "IP du service MongoDB: $mongoService" -ForegroundColor Cyan

# 8. Problèmes potentiels
Write-Host "`n🚨 8. DIAGNOSTIC PROBLÈMES:" -ForegroundColor Yellow
Write-Host "Pods en erreur:" -ForegroundColor Cyan
kubectl get pods --all-namespaces | Select-String "Error|CrashLoop|Pending"

Write-Host "`nRaison du pod ama-logs en Pending:" -ForegroundColor Cyan
kubectl get pod ama-logs-nk5md --namespace kube-system -o jsonpath='{.status.conditions[?(@.type=="PodScheduled")].message}'

Write-Host "`n✅ Monitoring termine!" -ForegroundColor Green
Write-Host "`n💡 CONSEIL:" -ForegroundColor Cyan
Write-Host "Les donnees Log Analytics peuvent prendre 5-15 minutes a apparaitre."
Write-Host "En attendant, utilisez ces commandes kubectl pour le monitoring en temps reel."

Write-Host "`n🔗 ACCES WEB:" -ForegroundColor Cyan
Write-Host "Container Insights: https://portal.azure.com/#@/resource/subscriptions/a56f5503-7af4-45e6-8f96-dd6c75a8883d/resourceGroups/aks-restored-rg/providers/Microsoft.ContainerService/managedClusters/K8workshopaks-restored/insights"