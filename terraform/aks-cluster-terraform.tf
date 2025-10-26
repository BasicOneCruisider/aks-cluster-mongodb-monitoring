# ================================================================
# MAIN TERRAFORM CONFIGURATION - AKS Cluster with MongoDB
# ================================================================
# 
# Ce fichier principal orchestre le déploiement d'un cluster AKS
# avec MongoDB via Helm. La configuration est organisée en modules
# logiques dans des fichiers séparés :
#
# - providers.tf    : Configuration des providers Terraform
# - variables.tf    : Définition des variables d'entrée  
# - data.tf         : Sources de données externes
# - infrastructure.tf : Ressources réseau et groupe de ressources
# - aks.tf          : Configuration du cluster AKS
# - kubernetes.tf   : Ressources Kubernetes et Helm
# - outputs.tf      : Valeurs de sortie
#
# Cluster: K8workshopaks-restored
# Resource Group: aks-restored-rg
# Date: 26 octobre 2025
# ================================================================

# Note: Toute la configuration est maintenant organisée dans des 
# fichiers spécialisés suivant les meilleures pratiques Terraform.
# Ce fichier sert de point d'entrée et de documentation principale.
