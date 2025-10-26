# ================================================================
# SCRIPT DE DÉPLOIEMENT TERRAFORM - AKS Cluster
# Cluster: K8workshopaks
# Date: 26 octobre 2025
# ================================================================

# Vérifier que Terraform est installé
try {
    terraform --version
    Write-Host "✅ Terraform est installé" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform n'est pas installé. Installation..." -ForegroundColor Red
    winget install Hashicorp.Terraform
}

# Se connecter à Azure
Write-Host "🔐 Connexion à Azure..." -ForegroundColor Yellow
az login

# Initialiser Terraform
Write-Host "🚀 Initialisation de Terraform..." -ForegroundColor Yellow
terraform init

# Valider la configuration
Write-Host "✔️ Validation de la configuration..." -ForegroundColor Yellow
terraform validate

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Configuration Terraform valide" -ForegroundColor Green
} else {
    Write-Host "❌ Erreurs de validation détectées" -ForegroundColor Red
    exit 1
}

# Planifier le déploiement
Write-Host "📋 Planification du déploiement..." -ForegroundColor Yellow
terraform plan -out=tfplan

# Appliquer le plan (avec confirmation)
Write-Host "🚀 Application du plan Terraform..." -ForegroundColor Yellow
terraform apply "tfplan"

# Configurer kubectl
Write-Host "⚙️ Configuration de kubectl..." -ForegroundColor Yellow
az aks get-credentials --resource-group Terible --name K8workshopaks --overwrite-existing

# Vérifier le déploiement
Write-Host "🔍 Vérification du déploiement..." -ForegroundColor Yellow
kubectl get nodes
kubectl get pods --namespace ratingapp

Write-Host "🎉 Déploiement terminé avec succès!" -ForegroundColor Green
Write-Host "🌐 Lien vers le portail Azure: https://portal.azure.com/#@/resource/subscriptions/a56f5503-7af4-45e6-8f96-dd6c75a8883d/resourceGroups/Terible/providers/Microsoft.ContainerService/managedClusters/K8workshopaks" -ForegroundColor Cyan