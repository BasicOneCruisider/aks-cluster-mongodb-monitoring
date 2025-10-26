# ================================================================
# SCRIPT DE RESTAURATION AKS via TERRAFORM
# Cluster: K8workshopaks - Version simplifiee
# ================================================================

Write-Host "================================================================" -ForegroundColor Magenta
Write-Host "🚀 RESTAURATION COMPLETE DU CLUSTER AKS via TERRAFORM" -ForegroundColor Magenta
Write-Host "================================================================" -ForegroundColor Magenta
Write-Host "Cluster cible: K8workshopaks" -ForegroundColor Cyan
Write-Host "Resource Group: Terible" -ForegroundColor Cyan
Write-Host "Location: France Central" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Magenta

# Etape 1: Verification des prerequis
Write-Host "🔄 Etape 1/7 - Verification des prerequis" -ForegroundColor Blue

# Verifier Terraform
Write-Host "Verification de Terraform..." -ForegroundColor Yellow
try {
    $tfVersion = terraform --version
    Write-Host "✅ Terraform installe: $($tfVersion.Split([Environment]::NewLine)[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform non trouve" -ForegroundColor Red
    Write-Host "Installation via winget..." -ForegroundColor Yellow
    winget install HashiCorp.Terraform
}

# Verifier Azure CLI
Write-Host "Verification d'Azure CLI..." -ForegroundColor Yellow
try {
    $azAccount = az account show --query "name" -o tsv
    Write-Host "✅ Connecte a Azure: $azAccount" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Non connecte a Azure. Connexion..." -ForegroundColor Yellow
    az login
}

# Etape 2: Initialisation Terraform
Write-Host "🔄 Etape 2/7 - Initialisation Terraform" -ForegroundColor Blue
terraform init -upgrade
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Terraform initialise avec succes" -ForegroundColor Green
} else {
    Write-Host "❌ Echec de l'initialisation" -ForegroundColor Red
    exit 1
}

# Etape 3: Validation
Write-Host "🔄 Etape 3/7 - Validation de la configuration" -ForegroundColor Blue
terraform validate
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Configuration Terraform valide" -ForegroundColor Green
} else {
    Write-Host "❌ Erreurs de validation detectees" -ForegroundColor Red
    exit 1
}

# Etape 4: Planification
Write-Host "🔄 Etape 4/7 - Planification du deploiement" -ForegroundColor Blue
terraform plan -var-file="terraform.tfvars" -out="aks-deployment.tfplan"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Plan de deploiement genere" -ForegroundColor Green
} else {
    Write-Host "❌ Echec de la planification" -ForegroundColor Red
    exit 1
}

# Confirmation
Write-Host ""
Write-Host "⚠️ ATTENTION: Le deploiement va creer des ressources Azure facturees" -ForegroundColor Yellow
Write-Host "💰 Cout estime: ~5-15€/jour selon l'utilisation" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Confirmer le deploiement? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "ℹ️ Deploiement annule par l'utilisateur" -ForegroundColor Cyan
    exit 0
}

# Etape 5: Application
Write-Host "🔄 Etape 5/7 - Application du deploiement" -ForegroundColor Blue
Write-Host "⏱️ Deploiement en cours... (10-15 minutes)" -ForegroundColor Yellow
$deployStart = Get-Date

terraform apply "aks-deployment.tfplan"

$deployEnd = Get-Date
$duration = $deployEnd - $deployStart

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deploiement termine avec succes en $($duration.ToString('mm\:ss'))" -ForegroundColor Green
} else {
    Write-Host "❌ Echec du deploiement" -ForegroundColor Red
    exit 1
}

# Etape 6: Configuration kubectl
Write-Host "🔄 Etape 6/7 - Configuration kubectl" -ForegroundColor Blue
az aks get-credentials --resource-group "Terible" --name "K8workshopaks" --overwrite-existing
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ kubectl configure avec succes" -ForegroundColor Green
} else {
    Write-Host "⚠️ Erreur lors de la configuration kubectl" -ForegroundColor Yellow
}

# Etape 7: Verification
Write-Host "🔄 Etape 7/7 - Verification du deploiement" -ForegroundColor Blue

Write-Host "Verification des noeuds..." -ForegroundColor Yellow
kubectl get nodes

Write-Host "Verification des applications..." -ForegroundColor Yellow
kubectl get pods --namespace ratingapp

# Affichage final
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "🎉 RESTAURATION COMPLETE TERMINEE AVEC SUCCES!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "ℹ️ Informations du cluster:" -ForegroundColor Cyan
Write-Host "  • Nom: K8workshopaks" -ForegroundColor White
Write-Host "  • Resource Group: Terible" -ForegroundColor White
Write-Host "  • Duree du deploiement: $($duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Liens utiles:" -ForegroundColor Cyan
Write-Host "  • Portal Azure: https://portal.azure.com" -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 Commandes utiles:" -ForegroundColor Cyan
Write-Host "  • Voir les noeuds: kubectl get nodes" -ForegroundColor Yellow
Write-Host "  • Voir les pods: kubectl get pods --all-namespaces" -ForegroundColor Yellow
Write-Host "  • Arreter le cluster: az aks stop --name K8workshopaks --resource-group Terible" -ForegroundColor Yellow
Write-Host "  • Outputs Terraform: terraform output" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️ N'oubliez pas d'arreter le cluster pour economiser les couts!" -ForegroundColor Yellow
Write-Host ""
Write-Host "================================================================" -ForegroundColor Magenta
Write-Host "🔧 Le cluster AKS est maintenant pret a etre utilise!" -ForegroundColor Magenta
Write-Host "================================================================" -ForegroundColor Magenta