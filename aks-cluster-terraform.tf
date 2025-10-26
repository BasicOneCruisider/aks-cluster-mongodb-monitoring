# ================================================================
# TERRAFORM CONFIGURATION - AKS Cluster Backup
# Cluster: K8workshopaks
# Resource Group: Terible
# Date: 26 octobre 2025
# ================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Configuration du provider Azure
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Configuration du provider Kubernetes
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Configuration du provider Helm
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# Variables
variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "Terible"
}

variable "cluster_name" {
  description = "Nom du cluster AKS"
  type        = string
  default     = "K8workshopaks"
}

variable "location" {
  description = "Localisation Azure"
  type        = string
  default     = "francecentral"
}

variable "kubernetes_version" {
  description = "Version de Kubernetes"
  type        = string
  default     = "1.32.7"
}

variable "node_count" {
  description = "Nombre de nœuds"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Taille des VMs"
  type        = string
  default     = "Standard_D2ps_v6"
}

# Créer le groupe de ressources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Workshop"
    Project     = "K8s-Learning"
    ManagedBy   = "Terraform"
    Backup      = "True"
  }
}

# Créer le réseau virtuel
resource "azurerm_virtual_network" "main" {
  name                = "${var.resource_group_name}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]

  tags = azurerm_resource_group.main.tags
}

# Créer le sous-réseau
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.1.0/24"]
}

data "azurerm_log_analytics_workspace" "main" {
  name                = "law-secops-poc-francecentral"
  resource_group_name = "rg-secops-poc-francecentral"
}

# Cluster AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  # Configuration de base
  sku_tier                          = "Free"
  support_plan                      = "KubernetesOfficial"
  role_based_access_control_enabled = true
  local_account_disabled            = false

  # Agent Pool par défaut
  default_node_pool {
    name            = "agentpool"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = 128
    os_disk_type    = "Managed"
    os_sku          = "Ubuntu"
    type            = "VirtualMachineScaleSets"
    zones           = ["1", "2", "3"]
    max_pods        = 110

    # Configuration réseau
    vnet_subnet_id = azurerm_subnet.default.id

    # Upgrade settings pour le node pool
    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Identité managée
  identity {
    type = "SystemAssigned"
  }

  # Configuration réseau
  network_profile {
    network_plugin     = "azure"
    network_data_plane = "azure"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"

    load_balancer_profile {
      managed_outbound_ip_count = 1
    }
  }

  # Configuration de mise à niveau automatique
  auto_scaler_profile {
    balance_similar_node_groups      = false
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
  }

  # Addons
  azure_policy_enabled = true
  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  }

  # OIDC Issuer
  oidc_issuer_enabled = true

  # Azure Monitor
  monitor_metrics {}

  # Configuration du stockage
  storage_profile {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  tags = {
    Environment = "Workshop"
    Project     = "K8s-Learning"
    ManagedBy   = "Terraform"
    Backup      = "True"
  }
}

# Namespace pour l'application rating
resource "kubernetes_namespace" "ratingapp" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = "ratingapp"
    labels = {
      name = "ratingapp"
    }
  }
}

# Installation MongoDB via Helm
resource "helm_release" "mongodb" {
  depends_on = [
    kubernetes_namespace.ratingapp
  ]

  name       = "ratings"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  namespace  = "ratingapp"

  values = [
    <<EOF
architecture: standalone
auth:
  enabled: true
  rootUser: root
service:
  type: ClusterIP
  ports:
    mongodb: 27017
persistence:
  enabled: true
  size: 8Gi
resources:
  limits:
    cpu: 750m
    memory: 768Mi
  requests:
    cpu: 500m
    memory: 512Mi
EOF
  ]

  timeout = 600
  wait    = true
}

# Secret personnalisé pour la connexion MongoDB
resource "kubernetes_secret" "mongo_secret" {
  depends_on = [kubernetes_namespace.ratingapp]

  metadata {
    name      = "mongosecret"
    namespace = "ratingapp"
  }

  type = "Opaque"

  data = {
    MONGOCONNECTION = "mongodb://Faris:Faris-2024@ratings-mongodb.ratingapp:27017/ratingapp"
  }
}

# Outputs
output "cluster_id" {
  description = "ID du cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_fqdn" {
  description = "FQDN du cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "cluster_portal_fqdn" {
  description = "FQDN du portail Azure pour le cluster"
  value       = azurerm_kubernetes_cluster.aks.portal_fqdn
}

output "kube_config" {
  description = "Configuration kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "cluster_identity" {
  description = "Identité managée du cluster"
  value = {
    principal_id = azurerm_kubernetes_cluster.aks.identity.0.principal_id
    tenant_id    = azurerm_kubernetes_cluster.aks.identity.0.tenant_id
  }
}

output "node_resource_group" {
  description = "Groupe de ressources des nœuds"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "mongodb_service_ip" {
  description = "IP du service MongoDB"
  value       = "ratings-mongodb.ratingapp.svc.cluster.local"
}

output "mongodb_connection_string" {
  description = "Chaîne de connexion MongoDB"
  value       = "mongodb://ratings-mongodb.ratingapp:27017"
  sensitive   = true
}
