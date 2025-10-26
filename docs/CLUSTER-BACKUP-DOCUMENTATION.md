# 📋 Documentation de Sauvegarde - Cluster AKS K8workshopaks

## 📊 Informations générales

- **Nom du cluster** : K8workshopaks
- **Groupe de ressources** : Terible
- **Localisation** : France Central
- **Version Kubernetes** : 1.32.7
- **Date de sauvegarde** : 26 octobre 2025
- **Type de sauvegarde** : Configuration et Infrastructure as Code

## 📁 Fichiers de sauvegarde créés

### 1. `aks-cluster-backup.yaml`

**Contenu** : Configuration complète du cluster en format YAML Kubernetes

- ConfigMaps avec toutes les configurations
- Instructions de restauration step-by-step
- Configuration des agent pools, réseau, sécurité
- Applications déployées (MongoDB via Helm)

### 2. `aks-cluster-terraform.tf`

**Contenu** : Infrastructure as Code complète en Terraform

- Ressource `azurerm_kubernetes_cluster` avec toutes les configurations
- Providers configurés (azurerm, kubernetes, helm)
- Déploiement automatique de MongoDB via Helm
- Variables et outputs pour réutilisation

### 3. `deploy-aks-terraform.ps1`

**Contenu** : Script PowerShell de déploiement automatisé

- Vérification des prérequis (Terraform, Azure CLI)
- Séquence complète de déploiement
- Configuration automatique de kubectl

### 4. `cluster-config.json`

**Contenu** : Export JSON complet de la configuration Azure

- Toutes les propriétés du cluster AKS
- Configuration détaillée des agent pools
- Profils réseau et sécurité

## 🏗️ Architecture sauvegardée

### **Cluster Principal**

- **SKU** : Free Tier
- **RBAC** : Activé
- **Version** : 1.32.7
- **DNS Prefix** : K8workshopaks-dns
- **Node Resource Group** : MC_Terible_K8workshopaks_westeurope

### **Agent Pool**

- **Nom** : agentpool
- **Nombre de nœuds** : 1
- **Taille VM** : Standard_D2ps_v6
- **OS** : Ubuntu 22.04 LTS
- **Disque OS** : 128 GB Managed
- **Zones de disponibilité** : 1, 2, 3
- **Max Pods par nœud** : 110

### **Configuration Réseau**

- **Plugin** : Azure CNI
- **Data Plane** : Azure
- **Service CIDR** : 10.0.0.0/16
- **DNS Service IP** : 10.0.0.10
- **Load Balancer** : Standard SKU
- **Outbound IPs** : 1 managée

### **Addons Activés**

- **Azure Policy** : ✅ Activé
- **OMS Agent** : ✅ Activé (Log Analytics)
- **Image Cleaner** : ✅ Activé (168h)
- **Workload Identity** : ✅ Activé
- **OIDC Issuer** : ✅ Activé

### **Applications Déployées**

- **MongoDB** : Version 8.2.1 (Chart Bitnami 18.1.1)
- **Namespace** : ratingapp
- **Service** : ClusterIP sur port 27017
- **Secrets** : Configuration d'authentification

## 🔄 Procédures de restauration

### **Option 1 : Terraform (Recommandée)**

```powershell
# 1. Cloner ou copier les fichiers
# 2. Exécuter le script de déploiement
.\deploy-aks-terraform.ps1
```

### **Option 2 : Azure CLI Manuel**

```bash
# 1. Créer le cluster
az aks create --resource-group Terible --name K8workshopaks --location francecentral --kubernetes-version 1.32.7 --node-count 1 --node-vm-size Standard_D2ps_v6 --network-plugin azure --service-cidr 10.0.0.0/16 --dns-service-ip 10.0.0.10 --enable-rbac

# 2. Configurer kubectl
az aks get-credentials --resource-group Terible --name K8workshopaks

# 3. Appliquer les configurations YAML
kubectl apply -f aks-cluster-backup.yaml
```

### **Option 3 : Helm pour les applications**

```bash
# 1. Ajouter les repositories
helm repo add bitnami https://charts.bitnami.com/bitnami

# 2. Installer MongoDB
helm install ratings bitnami/mongodb --namespace ratingapp --create-namespace

# 3. Créer les secrets
kubectl create secret generic mongosecret --namespace ratingapp --from-literal=MONGOCONNECTION="mongodb://Faris:Faris-2024@ratings-mongodb.ratingapp:27017/ratingapp"
```

## 💾 Données de connexion

### **MongoDB**

- **Service interne** : `ratings-mongodb.ratingapp.svc.cluster.local:27017`
- **Namespace** : `ratingapp`
- **Utilisateur** : `root` (mot de passe dans secret)
- **Base de données** : `ratingapp`

### **Secrets Kubernetes**

- **mongosecret** : Chaîne de connexion personnalisée
- **ratings-mongodb** : Credentials MongoDB générés par Helm

## 🔐 Sécurité

### **Identités**

- **System Assigned Identity** : Activée pour le cluster
- **Kubelet Identity** : User Assigned Identity pour les nœuds
- **Azure Policy Identity** : Pour la conformité

### **Authentification**

- **RBAC** : Activé
- **Local Accounts** : Activés
- **OIDC Issuer** : Activé pour Workload Identity
- **AAD Integration** : Via OIDC

## 📈 Monitoring et Observabilité

### **Azure Monitor**

- **Metrics** : Activé
- **Container Insights** : Via OMS Agent
- **Log Analytics** : Workspace partagé

### **Health Checks**

- **Image Cleaner** : Toutes les 168 heures
- **Node Health** : Monitoring automatique
- **Pod Health** : Liveness/Readiness probes

## 💰 Optimisation des coûts

### **Recommandations**

1. **Arrêt automatique** : `az aks stop` en fin de journée
2. **Scaling** : Réduire le nombre de nœuds si non utilisé
3. **Monitoring** : Surveiller l'utilisation des ressources
4. **Cleanup** : Supprimer les workloads non utilisés

### **Commandes utiles**

```bash
# Arrêter le cluster
az aks stop --name K8workshopaks --resource-group Terible

# Redémarrer le cluster
az aks start --name K8workshopaks --resource-group Terible

# Vérifier l'état
az aks show --name K8workshopaks --resource-group Terible --query "powerState.code"
```

## 🚀 Liens utiles

- **Portail Azure** : [Cluster K8workshopaks](https://portal.azure.com/#@/resource/subscriptions/a56f5503-7af4-45e6-8f96-dd6c75a8883d/resourceGroups/Terible/providers/Microsoft.ContainerService/managedClusters/K8workshopaks)
- **Documentation AKS** : https://docs.microsoft.com/azure/aks/
- **Terraform Provider** : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
- **Helm Charts Bitnami** : https://github.com/bitnami/charts

---

**Note** : Cette sauvegarde contient toutes les informations nécessaires pour recréer le cluster identique. Assurez-vous de conserver ces fichiers en lieu sûr ! 🔐
