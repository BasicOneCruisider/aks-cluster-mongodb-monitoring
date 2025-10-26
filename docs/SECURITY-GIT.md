# 🔐 Guide de Sécurité Git pour Projet AKS

## 🚨 ATTENTION - FICHIERS SENSIBLES

Ce projet contient des configurations Azure et Kubernetes qui peuvent exposer des informations sensibles. Suivez **strictement** ce guide avant tout commit.

## 📋 Checklist de Sécurité Pre-Commit

### ✅ Fichiers à NE JAMAIS committer

- ❌ `terraform.tfvars` (contient IDs de subscription, noms réels)
- ❌ `terraform.tfstate*` (contient état complet de l'infrastructure)
- ❌ `cluster-config.json` (contient IDs, tokens, URLs FQDN)
- ❌ `.terraform/` (cache Terraform)
- ❌ `.kube/config` (credentials kubectl)
- ❌ `*.log` (logs peuvent contenir des secrets)
- ❌ Fichiers avec mots de passe/clés/tokens

### ✅ Fichiers sécurisés à committer

- ✅ `*.template` (templates sans vraies valeurs)
- ✅ `*.tf` (définitions Terraform sans secrets)
- ✅ `*.yaml` (manifests K8s sans secrets inline)
- ✅ `*.ps1` (scripts sans credentials hardcodés)
- ✅ `*.md` (documentation)
- ✅ `*.kql` (requêtes de monitoring)
- ✅ `.gitignore` (configuration Git)

## 🛡️ Utilisation des Templates

### Template Terraform

```bash
# AU LIEU DE committer terraform.tfvars
cp terraform.tfvars.template terraform.tfvars
# Modifiez terraform.tfvars avec vos vraies valeurs
# Committez SEULEMENT terraform.tfvars.template
```

### Template Cluster Config

```bash
# AU LIEU DE committer cluster-config.json
cp cluster-config.template.json cluster-config.json
# Modifiez cluster-config.json avec vos vraies valeurs
# Committez SEULEMENT cluster-config.template.json
```

## 🔧 Processus de Sécurisation

### 1. Exécuter le script de sécurisation

```powershell
.\git-secure-init.ps1
```

### 2. Vérification manuelle

```bash
# Vérifier les fichiers qui seront committés
git status

# Vérifier le contenu des fichiers staged
git diff --cached

# Rechercher des patterns suspects
git grep -E "(subscription|tenant|password|secret|key.*=)" --cached
```

### 3. Patterns à surveiller

⚠️ **Recherchez ces patterns dans vos fichiers avant commit:**

- Subscription IDs: `a56f5503-7af4-45e6-8f96-dd6c75a8883d`
- Tenant IDs: `dcde988f-97f6-48bb-acfc-eb7fa878e40e`
- Client IDs: `6beec251-c8a6-4285-a0c6-b95f2ea7b255`
- URLs FQDN: `*.hcp.francecentral.azmk8s.io`
- Resource IDs complets
- Noms de ressources en production

## 🔄 Workflow Git Sécurisé

### Première initialisation

```bash
# 1. Exécuter le script de sécurisation
.\git-secure-init.ps1

# 2. Si tout est OK, initialiser Git
git init
git add .
git commit -m "Initial commit: AKS project with secure templates"

# 3. Ajouter le remote (remplacez par votre URL)
git remote add origin https://github.com/votre-username/votre-repo.git
git branch -M main
git push -u origin main
```

### Commits ultérieurs

```bash
# 1. Toujours vérifier avant de stage
git status

# 2. Vérifier que pas de fichiers sensibles
ls terraform.tfvars cluster-config.json *.log 2>/dev/null || echo "OK"

# 3. Stageer seulement les fichiers sûrs
git add *.md *.template *.tf *.ps1 *.yaml *.kql .gitignore

# 4. Vérifier ce qui sera committé
git diff --cached

# 5. Commit si OK
git commit -m "Votre message"
```

## 🚨 En cas d'erreur - Fichier sensible committé

### Si vous avez committé un fichier sensible PAR ERREUR:

```bash
# 1. Supprimer le fichier du dernier commit (avant push)
git reset --soft HEAD~1
git reset HEAD fichier-sensible.ext
git commit -m "Commit corrigé sans fichier sensible"

# 2. Si déjà pushé (URGENT - notifiez votre équipe)
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch fichier-sensible.ext' \
--prune-empty --tag-name-filter cat -- --all

# 3. Force push (DANGEREUX - coordonnez avec l'équipe)
git push --force-with-lease
```

### Rotation des secrets exposés

Si des secrets ont été exposés:

1. **Immédiatement**: Régénérer tous les secrets/clés exposés
2. **Terraform**: Créer nouveau Service Principal
3. **Azure**: Régénérer les clés d'accès
4. **Kubernetes**: Recréer les secrets

## 📊 Outils recommandés

### Git Secrets (recommandé)

```bash
# Installation
git secrets --install
git secrets --register-aws

# Scan avant commit
git secrets --scan
```

### Pre-commit hooks

```bash
# Installer pre-commit
pip install pre-commit

# .pre-commit-config.yaml
echo "
repos:
-   repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
    -   id: detect-secrets
" > .pre-commit-config.yaml

pre-commit install
```

## 📝 Templates de messages de commit

### Pour des changements de configuration

```
feat: add monitoring configuration template

- Add KQL queries for cluster monitoring
- Add PowerShell monitoring scripts
- Template files for secure deployment
```

### Pour des corrections de sécurité

```
security: update .gitignore patterns

- Add terraform state files to .gitignore
- Add cluster config patterns
- Add credentials patterns
```

## 🔗 Ressources utiles

- [Git Secrets](https://github.com/awslabs/git-secrets)
- [Detect Secrets](https://github.com/Yelp/detect-secrets)
- [Azure Security Best Practices](https://docs.microsoft.com/azure/security/)
- [Terraform Security](https://learn.hashicorp.com/tutorials/terraform/sensitive-variables)

## ⚠️ Rappel Important

**AVANT CHAQUE COMMIT:**

1. ✅ Exécutez `.\git-secure-init.ps1`
2. ✅ Vérifiez `git status` et `git diff --cached`
3. ✅ Confirmez qu'aucun secret n'est exposé
4. ✅ Utilisez les templates pour les configurations

**La sécurité est la responsabilité de tous!** 🛡️
