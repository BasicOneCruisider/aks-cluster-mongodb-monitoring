# 🚀 Guide de création du repository GitHub

## Étapes pour créer le repository distant

### 1. Créer le repository sur GitHub.com

1. **Aller sur GitHub** : https://github.com
2. **Se connecter** à votre compte GitHub
3. **Cliquer sur "New repository"** (bouton vert) ou aller sur https://github.com/new
4. **Remplir les informations** :
   - **Repository name** : `aks-cluster-mongodb-monitoring`
   - **Description** : `AKS cluster with MongoDB and Azure monitoring - Infrastructure as Code`
   - **Visibility** :
     - ✅ **Public** (si vous voulez le partager)
     - ✅ **Private** (recommandé pour projets d'entreprise)
   - **Initialize** :
     - ❌ **Ne PAS** cocher "Add a README file" (on en a déjà un)
     - ❌ **Ne PAS** ajouter .gitignore (on en a déjà un)
     - ❌ **Ne PAS** choisir de licence pour l'instant
5. **Cliquer "Create repository"**

### 2. GitHub vous donnera les commandes à exécuter

Après création, GitHub affichera quelque chose comme :

```bash
git remote add origin https://github.com/VOTRE-USERNAME/aks-cluster-mongodb-monitoring.git
git branch -M main
git push -u origin main
```

### 3. Exécuter les commandes ici

**Remplacez `VOTRE-USERNAME` par votre vrai nom d'utilisateur GitHub**

```powershell
# Ajouter le remote (remplacez par votre URL)
git remote add origin https://github.com/VOTRE-USERNAME/aks-cluster-mongodb-monitoring.git

# Pousser vers GitHub
git push -u origin main
```

## Option 2: Créer via GitHub CLI (si installé)

Si vous avez GitHub CLI installé :

```powershell
# Créer le repo directement
gh repo create aks-cluster-mongodb-monitoring --private --description "AKS cluster with MongoDB and Azure monitoring"

# Pousser le code
git push -u origin main
```

## Option 3: Créer via Azure DevOps

Si vous préférez Azure DevOps :

1. Aller sur https://dev.azure.com
2. Créer un nouveau projet
3. Aller dans Repos > Files
4. Copier l'URL de clone
5. Exécuter :

```powershell
git remote add origin https://VOTRE-ORG@dev.azure.com/VOTRE-ORG/VOTRE-PROJECT/_git/aks-cluster
git push -u origin main
```

## ⚠️ Important - Vérification finale avant push

Avant de pousser, vérifiez une dernière fois qu'aucun secret n'est exposé :

```powershell
# Vérification rapide
.\git-check-simple.ps1

# Voir ce qui sera poussé
git log --oneline
git show --name-only

# Vérifier qu'aucun fichier sensible n'est tracké
git ls-files | Select-String "terraform.tfvars$|.tfstate|cluster-config.json$"
```

Si cette dernière commande ne retourne rien, c'est parfait ! ✅

## 🎯 Nom de repository recommandé

**Suggestions de noms :**

- `aks-cluster-mongodb-monitoring`
- `azure-aks-infrastructure`
- `k8s-mongodb-terraform-project`
- `aks-cluster-iac` (Infrastructure as Code)

## 📝 Tags recommandés pour GitHub

- `azure`
- `kubernetes`
- `terraform`
- `mongodb`
- `monitoring`
- `aks`
- `infrastructure-as-code`
- `helm`

---

**Prêt ? Créez votre repository et je vous aide avec les commandes suivantes !** 🚀
