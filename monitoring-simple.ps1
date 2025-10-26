# MONITORING CLUSTER AKS - TEMPS REEL
# ====================================

Write-Host "MONITORING CLUSTER AKS - TEMPS REEL" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# 1. Etat general du cluster
Write-Host "`n1. ETAT DU CLUSTER:" -ForegroundColor Yellow
kubectl get nodes -o wide

# 2. Utilisation des ressources
Write-Host "`n2. UTILISATION DES RESSOURCES:" -ForegroundColor Yellow
kubectl top nodes
kubectl top pods --all-namespaces

# 3. Etat MongoDB
Write-Host "`n3. ETAT MONGODB:" -ForegroundColor Yellow
kubectl get pods --namespace ratingapp -o wide
kubectl get services --namespace ratingapp

# 4. Logs MongoDB recents
Write-Host "`n4. LOGS MONGODB (dernieres 10 lignes):" -ForegroundColor Yellow
kubectl logs --namespace ratingapp ratings-mongodb-77b48c69c6-b52rs --tail=10

# 5. Evenements recents
Write-Host "`n5. EVENEMENTS RECENTS:" -ForegroundColor Yellow
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | Select-Object -Last 10

# 6. Agents de monitoring
Write-Host "`n6. AGENTS DE MONITORING:" -ForegroundColor Yellow
kubectl get pods --namespace kube-system | Select-String "ama-"

Write-Host "`nMonitoring termine!" -ForegroundColor Green