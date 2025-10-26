# ==========================================
# SCRIPT DE SECURISATION GIT - AKS PROJECT
# ==========================================

Write-Host "🔐 INITIALISATION SECURISEE DU REPOSITORY GIT" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Vérifier si Git est installé
try {
    git --version | Out-Null
    Write-Host "✅ Git est installé" -ForegroundColor Green
} catch {
    Write-Host "❌ Git n'est pas installé. Installez Git d'abord." -ForegroundColor Red
    exit 1
}

# Vérifier la présence du .gitignore
if (Test-Path ".gitignore") {
    Write-Host "✅ Fichier .gitignore trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Fichier .gitignore manquant" -ForegroundColor Red
    exit 1
}

Write-Host "`n🔍 AUDIT DES FICHIERS SENSIBLES" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow

# Liste des fichiers potentiellement sensibles
$FilesWithSecrets = @(
    "terraform.tfvars",
    "terraform.tfstate",
    "terraform.tfstate.backup", 
    "cluster-config.json",
    ".terraform/",
    ".kube/config",
    "*.log"
)

$FoundSensitiveFiles = @()

foreach ($pattern in $FilesWithSecrets) {
    $files = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
    if ($files) {
        $FoundSensitiveFiles += $files
        foreach ($file in $files) {
            Write-Host "⚠️  FICHIER SENSIBLE TROUVÉ: $($file.Name)" -ForegroundColor Red
        }
    }
}

if ($FoundSensitiveFiles.Count -eq 0) {
    Write-Host "✅ Aucun fichier sensible détecté" -ForegroundColor Green
} else {
    Write-Host "`n🛡️  RECOMMANDATIONS DE SÉCURITÉ:" -ForegroundColor Yellow
    Write-Host "- Vérifiez que ces fichiers sont dans .gitignore" -ForegroundColor Yellow
    Write-Host "- Utilisez les templates (.template) à la place" -ForegroundColor Yellow
    Write-Host "- Ne committez JAMAIS ces fichiers" -ForegroundColor Yellow
}

Write-Host "`n🔧 VERIFICATION DU .GITIGNORE" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

# Vérifier que les patterns essentiels sont dans .gitignore
$RequiredPatterns = @(
    "*.tfstate",
    "terraform.tfvars",
    "cluster-config.json",
    ".terraform/",
    "*.log"
)

$gitignoreContent = Get-Content ".gitignore" -ErrorAction SilentlyContinue
$MissingPatterns = @()

foreach ($pattern in $RequiredPatterns) {
    $found = $false
    foreach ($line in $gitignoreContent) {
        if ($line -match [regex]::Escape($pattern) -or $line -contains $pattern) {
            $found = $true
            break
        }
    }
    if (-not $found) {
        $MissingPatterns += $pattern
        Write-Host "⚠️  Pattern manquant dans .gitignore: $pattern" -ForegroundColor Red
    } else {
        Write-Host "✅ Pattern trouvé: $pattern" -ForegroundColor Green
    }
}

Write-Host "`n🚀 INITIALISATION DU REPOSITORY GIT" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

# Initialiser Git si ce n'est pas déjà fait
if (-not (Test-Path ".git")) {
    Write-Host "📁 Initialisation du repository Git..." -ForegroundColor Cyan
    git init
    Write-Host "✅ Repository Git initialisé" -ForegroundColor Green
} else {
    Write-Host "✅ Repository Git déjà initialisé" -ForegroundColor Green
}

Write-Host "`n🔍 VERIFICATION DES FICHIERS A COMMITTER" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Ajouter tous les fichiers sauf ceux ignorés
git add .

# Afficher le statut
Write-Host "📋 Statut Git:" -ForegroundColor Cyan
git status --porcelain

Write-Host "`n🔐 SCAN DE SÉCURITÉ FINAL" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Vérifier les fichiers staged pour des secrets potentiels
$StagedFiles = git diff --cached --name-only

$SecretPatterns = @(
    "subscription",
    "tenant", 
    "clientId",
    "password",
    "secret",
    "key.*=",
    "token"
)

$PotentialSecrets = @()

foreach ($file in $StagedFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -ErrorAction SilentlyContinue
        foreach ($line in $content) {
            foreach ($pattern in $SecretPatterns) {
                if ($line -match $pattern -and $line -notmatch "XXXX|YOUR-|template|example") {
                    $PotentialSecrets += "$file : $line"
                    Write-Host "⚠️  POTENTIEL SECRET: $file" -ForegroundColor Red
                    Write-Host "    Ligne: $($line.Substring(0, [Math]::Min(50, $line.Length)))..." -ForegroundColor Yellow
                }
            }
        }
    }
}

Write-Host "`n📊 RÉSUMÉ DE SÉCURITÉ" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green

Write-Host "Fichiers sensibles trouvés: $($FoundSensitiveFiles.Count)" -ForegroundColor $(if ($FoundSensitiveFiles.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Patterns .gitignore manquants: $($MissingPatterns.Count)" -ForegroundColor $(if ($MissingPatterns.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Secrets potentiels détectés: $($PotentialSecrets.Count)" -ForegroundColor $(if ($PotentialSecrets.Count -eq 0) { "Green" } else { "Red" })

if ($FoundSensitiveFiles.Count -eq 0 -and $MissingPatterns.Count -eq 0 -and $PotentialSecrets.Count -eq 0) {
    Write-Host "`n🎉 REPOSITORY SÉCURISÉ - PRÊT POUR LE COMMIT!" -ForegroundColor Green
    Write-Host "`nCommandes suivantes recommandées:" -ForegroundColor Cyan
    Write-Host "git commit -m 'Initial commit: AKS cluster project with MongoDB and monitoring'" -ForegroundColor Gray
    Write-Host "git branch -M main" -ForegroundColor Gray
    Write-Host "git remote add origin <your-repo-url>" -ForegroundColor Gray
    Write-Host "git push -u origin main" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  ATTENTION: VÉRIFICATIONS REQUISES AVANT COMMIT" -ForegroundColor Red
    Write-Host "Corrigez les problèmes détectés ci-dessus" -ForegroundColor Yellow
}

Write-Host "`n📝 RAPPELS IMPORTANTS:" -ForegroundColor Cyan
Write-Host "- Utilisez les fichiers .template pour vos configurations" -ForegroundColor White
Write-Host "- Ne committez JAMAIS terraform.tfvars ou cluster-config.json" -ForegroundColor White
Write-Host "- Vérifiez toujours avec 'git diff --cached' avant de committer" -ForegroundColor White
Write-Host "- Utilisez 'git secrets' si disponible pour scanner automatiquement" -ForegroundColor White