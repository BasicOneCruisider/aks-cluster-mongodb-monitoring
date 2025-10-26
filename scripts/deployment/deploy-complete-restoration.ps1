#!/usr/bin/env powershell
# ================================================================
# SCRIPT DE RESTAURATION COMPLÈTE AKS via TERRAFORM
# Cluster: K8workshopaks
# Date: 26 octobre 2025
# ================================================================

param(
    [switch]$Force,
    [switch]$SkipValidation,
    [string]$VarFile = "terraform.tfvars"
)

# Configuration des couleurs pour les messages
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Step { param($Message) Write-Host "🔄 $Message" -ForegroundColor Blue }

Write-Host @"
================================================================
🚀 RESTAURATION COMPLÈTE DU CLUSTER AKS via TERRAFORM
================================================================
Cluster cible: K8workshopaks
Resource Group: Terible
Location: France Central
================================================================
"@ -ForegroundColor Magenta

# Étape 1: Vérification des prérequis
Write-Step "Étape 1/8 - Vérification des prérequis"

# Vérifier Terraform
try {
    $tfVersion = terraform --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Terraform installé: $($tfVersion.Split("`n")[0])"
    } else {
        throw "Terraform non trouvé"
    }
} catch {
    Write-Error "Terraform n'est pas installé ou accessible"
    Write-Info "Installation automatique via winget..."
    winget install HashiCorp.Terraform
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec de l'installation de Terraform"
        exit 1
    }
}

# Vérifier Azure CLI
try {
    $azVersion = az --version 2>$null | Select-String "azure-cli"
    if ($azVersion) {
        Write-Success "Azure CLI installé: $($azVersion.ToString().Trim())"
    } else {
        throw "Azure CLI non trouvé"
    }
} catch {
    Write-Error "Azure CLI n'est pas installé"
    Write-Info "Veuillez installer Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
}

# Vérifier la connexion Azure
Write-Step "Vérification de la connexion Azure..."
try {
    $azAccount = az account show --query "name" -o tsv 2>$null
    if ($azAccount) {
        Write-Success "Connecté à Azure: $azAccount"
    } else {
        throw "Non connecté"
    }
} catch {
    Write-Warning "Non connecté à Azure. Connexion en cours..."
    az login
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec de la connexion Azure"
        exit 1
    }
}

# Étape 2: Vérification des fichiers Terraform
Write-Step "Étape 2/8 - Vérification des fichiers Terraform"

$requiredFiles = @("variables.tf", "terraform.tfvars", "aks-cluster-terraform.tf", "outputs.tf", "versions.tf")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Success "Fichier présent: $file"
    } else {
        $missingFiles += $file
        Write-Error "Fichier manquant: $file"
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Error "Fichiers manquants détectés. Arrêt du déploiement."
    exit 1
}

# Étape 3: Vérification des ressources existantes
Write-Step "Étape 3/8 - Vérification des ressources existantes"

# Vérifier si le cluster existe déjà
$existingCluster = az aks show --name "K8workshopaks" --resource-group "Terible" 2>$null
if ($existingCluster) {
    Write-Warning "Un cluster AKS 'K8workshopaks' existe déjà"
    if (-not $Force) {
        $continue = Read-Host "Voulez-vous continuer et potentiellement recréer le cluster? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Info "Déploiement annulé par l'utilisateur"
            exit 0
        }
    }
} else {
    Write-Success "Aucun cluster existant détecté"
}

# Étape 4: Initialisation de Terraform
Write-Step "Étape 4/8 - Initialisation de Terraform"

Write-Info "Initialisation du répertoire Terraform..."
terraform init -upgrade
if ($LASTEXITCODE -ne 0) {
    Write-Error "Échec de l'initialisation Terraform"
    exit 1
}
Write-Success "Terraform initialisé avec succès"

# Étape 5: Validation de la configuration
Write-Step "Étape 5/8 - Validation de la configuration"

if (-not $SkipValidation) {
    Write-Info "Validation de la syntaxe Terraform..."
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreurs de validation détectées"
        Write-Info "Utilisez -SkipValidation pour ignorer cette étape"
        exit 1
    }
    Write-Success "Configuration Terraform valide"
} else {
    Write-Warning "Validation ignorée (-SkipValidation activé)"
}

# Étape 6: Planification du déploiement
Write-Step "Étape 6/8 - Planification du déploiement"

Write-Info "Génération du plan de déploiement..."
terraform plan -var-file="$VarFile" -out="aks-deployment.tfplan"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Échec de la planification"
    exit 1
}

Write-Success "Plan de déploiement généré: aks-deployment.tfplan"
Write-Info "Résumé du plan:"
terraform show -no-color "aks-deployment.tfplan" | Select-String "Plan:" -A 5

# Confirmation avant application
if (-not $Force) {
    Write-Host "`n" -NoNewline
    Write-Warning "ATTENTION: Le déploiement va créer des ressources Azure facturées"
    Write-Info "Coût estimé: ~5-15€/jour selon l'utilisation"
    Write-Host "`n" -NoNewline
    $confirm = Read-Host "Confirmer le déploiement? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Info "Déploiement annulé par l'utilisateur"
        Write-Info "Le plan est sauvegardé dans 'aks-deployment.tfplan'"
        exit 0
    }
}

# Étape 7: Application du déploiement
Write-Step "Étape 7/8 - Application du déploiement"

Write-Info "Déploiement en cours... (Cela peut prendre 10-15 minutes)"
$deployStart = Get-Date

terraform apply "aks-deployment.tfplan"
$deployResult = $LASTEXITCODE

$deployEnd = Get-Date
$deployDuration = $deployEnd - $deployStart

if ($deployResult -eq 0) {
    Write-Success "Déploiement terminé avec succès en $($deployDuration.ToString('mm\:ss'))"
} else {
    Write-Error "Échec du déploiement"
    Write-Info "Consultez les logs ci-dessus pour plus de détails"
    exit 1
}

# Étape 8: Configuration post-déploiement
Write-Step "Étape 8/8 - Configuration post-déploiement"

Write-Info "Configuration de kubectl..."
az aks get-credentials --resource-group "Terible" --name "K8workshopaks" --overwrite-existing
if ($LASTEXITCODE -eq 0) {
    Write-Success "kubectl configuré avec succès"
} else {
    Write-Warning "Erreur lors de la configuration kubectl"
}

Write-Info "Vérification de la connectivité au cluster..."
$nodes = kubectl get nodes --no-headers 2>$null
if ($nodes) {
    Write-Success "Cluster accessible - Nœuds détectés:"
    kubectl get nodes
} else {
    Write-Warning "Problème de connectivité au cluster"
}

Write-Info "Vérification des applications déployées..."
$pods = kubectl get pods --namespace ratingapp --no-headers 2>$null
if ($pods) {
    Write-Success "Applications déployées dans le namespace 'ratingapp':"
    kubectl get pods --namespace ratingapp
} else {
    Write-Warning "Aucune application détectée dans le namespace 'ratingapp'"
}

# Affichage des informations finales
Write-Host @"

================================================================
🎉 RESTAURATION COMPLÈTE TERMINÉE AVEC SUCCÈS!
================================================================
"@ -ForegroundColor Green

Write-Info "Informations du cluster:"
Write-Host "  • Nom: K8workshopaks" -ForegroundColor White
Write-Host "  • Resource Group: Terible" -ForegroundColor White
Write-Host "  • Location: France Central" -ForegroundColor White
Write-Host "  • Durée du déploiement: $($deployDuration.ToString('mm\:ss'))" -ForegroundColor White

Write-Info "Liens utiles:"
Write-Host "  • Portail Azure: https://portal.azure.com/#@/resource/subscriptions/.../resourceGroups/Terible/providers/Microsoft.ContainerService/managedClusters/K8workshopaks" -ForegroundColor Cyan

Write-Info "Commandes utiles:"
Write-Host "  • Voir les nœuds: kubectl get nodes" -ForegroundColor Yellow
Write-Host "  • Voir les pods: kubectl get pods --all-namespaces" -ForegroundColor Yellow
Write-Host "  • Arrêter le cluster: az aks stop --name K8workshopaks --resource-group Terible" -ForegroundColor Yellow
Write-Host "  • Outputs Terraform: terraform output" -ForegroundColor Yellow

Write-Warning "N'oubliez pas d'arrêter le cluster quand vous avez terminé pour économiser les coûts!"

Write-Host @"
================================================================
🔧 Le cluster AKS est maintenant prêt à être utilisé!
================================================================
"@ -ForegroundColor Magenta