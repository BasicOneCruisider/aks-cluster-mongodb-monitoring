# ==========================================
# SCRIPT DE VERIFICATION SIMPLE - GIT SECURITY
# ==========================================

Write-Host "🔐 VERIFICATION RAPIDE DES FICHIERS SENSIBLES" -ForegroundColor Green

# Vérifier les fichiers sensibles
$SensitiveFiles = @(
    "terraform.tfvars",
    "terraform.tfstate", 
    "terraform.tfstate.backup",
    "cluster-config.json"
)

Write-Host "`n🔍 Fichiers sensibles détectés:" -ForegroundColor Yellow

foreach ($file in $SensitiveFiles) {
    if (Test-Path $file) {
        Write-Host "❌ TROUVÉ: $file" -ForegroundColor Red
    } else {
        Write-Host "✅ OK: $file (non présent)" -ForegroundColor Green
    }
}

# Vérifier .gitignore
Write-Host "`n📝 Vérification .gitignore:" -ForegroundColor Yellow

if (Test-Path ".gitignore") {
    Write-Host "✅ .gitignore existe" -ForegroundColor Green
    
    $gitignoreContent = Get-Content ".gitignore"
    $patterns = @("terraform.tfvars", "*.tfstate", "cluster-config.json")
    
    foreach ($pattern in $patterns) {
        if ($gitignoreContent -match [regex]::Escape($pattern) -or $gitignoreContent -contains $pattern) {
            Write-Host "✅ Pattern '$pattern' trouvé dans .gitignore" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Pattern '$pattern' manquant dans .gitignore" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "❌ .gitignore manquant" -ForegroundColor Red
}

# Status Git
Write-Host "`n📊 Status Git:" -ForegroundColor Yellow

try {
    if (Test-Path ".git") {
        git status --porcelain | ForEach-Object {
            if ($_ -match "(terraform\.tfvars|\.tfstate|cluster-config\.json)") {
                Write-Host "❌ FICHIER SENSIBLE STAGÉ: $_" -ForegroundColor Red
            } else {
                Write-Host "✅ OK: $_" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "ℹ️  Git non initialisé" -ForegroundColor Cyan
    }
} catch {
    Write-Host "ℹ️  Git non configuré" -ForegroundColor Cyan
}

Write-Host "`n🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Vérifiez que les fichiers sensibles sont dans .gitignore" -ForegroundColor White
Write-Host "2. Utilisez les templates (.template) pour vos configurations" -ForegroundColor White  
Write-Host "3. Initialisez Git avec: git init" -ForegroundColor White
Write-Host "4. Ajoutez les fichiers sûrs: git add *.template *.md *.tf" -ForegroundColor White