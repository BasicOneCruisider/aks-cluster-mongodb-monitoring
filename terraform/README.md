# 🏗️ Structure Terraform - AKS Cluster with MongoDB

Cette configuration Terraform suit les **meilleures pratiques** en séparant les composants dans des fichiers spécialisés pour une meilleure lisibilité et maintenance.

## 📁 Structure des fichiers

```
terraform/
├── aks-cluster-terraform.tf    # 📋 Point d'entrée et documentation
├── providers.tf               # ⚙️ Configuration des providers
├── variables.tf               # 📝 Variables d'entrée
├── data.tf                    # 🔍 Sources de données externes
├── infrastructure.tf          # 🌐 Réseau et groupe de ressources
├── aks.tf                     # ☸️ Configuration cluster AKS
├── kubernetes.tf              # 🐳 Ressources K8s et Helm
├── outputs.tf                 # 📤 Valeurs de sortie
└── README.md                  # 📚 Cette documentation
```

## 🎯 Description des fichiers

### `providers.tf`
- Configuration Terraform et providers requis
- Configuration Azure, Kubernetes et Helm providers
- Versions et authentification

### `variables.tf`
- Toutes les variables d'entrée avec descriptions
- Valeurs par défaut configurables
- Types et validations

### `data.tf`
- Sources de données externes (Log Analytics workspace)
- Références à des ressources existantes

### `infrastructure.tf`
- Groupe de ressources Azure
- Réseau virtuel et sous-réseaux
- Ressources réseau de base

### `aks.tf`
- Configuration complète du cluster AKS
- Node pools et mise à l'échelle
- Addons et monitoring
- Profils réseau et sécurité

### `kubernetes.tf`
- Namespaces Kubernetes
- Déploiement MongoDB via Helm
- Secrets et configurations K8s

### `outputs.tf`
- Informations du cluster déployé
- Chaînes de connexion
- IDs et URLs importantes

## 🚀 Utilisation

```bash
# Initialiser Terraform
terraform init

# Valider la configuration
terraform validate

# Planifier le déploiement
terraform plan

# Appliquer les changements
terraform apply

# Détruire l'infrastructure
terraform destroy
```

## 🔧 Configuration

Copiez et modifiez le fichier de variables :
```bash
cp ../config/terraform.tfvars.template terraform.tfvars
```

## 📊 Avantages de cette structure

- ✅ **Séparation des responsabilités** : Chaque fichier a un rôle spécifique
- ✅ **Maintenance facilitée** : Modifications ciblées et claires
- ✅ **Réutilisabilité** : Variables et modules réutilisables
- ✅ **Lisibilité** : Code organisé et documenté
- ✅ **Collaboration** : Structure standard pour équipes
- ✅ **Debugging** : Isolement des problèmes par composant

## 🛡️ Sécurité

- Variables sensibles marquées comme `sensitive`
- Templates séparés des valeurs réelles
- Exclusion des fichiers sensibles via `.gitignore`