# ================================================================
# VARIABLES - AKS Cluster Configuration
# ================================================================

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

variable "log_analytics_workspace_name" {
  description = "Nom du workspace Log Analytics"
  type        = string
  default     = "law-secops-poc-francecentral"
}

variable "log_analytics_resource_group" {
  description = "Groupe de ressources du workspace Log Analytics"
  type        = string
  default     = "rg-secops-poc-francecentral"
}

variable "mongodb_auth_enabled" {
  description = "Activer l'authentification MongoDB"
  type        = bool
  default     = true
}

variable "mongodb_root_user" {
  description = "Utilisateur root MongoDB"
  type        = string
  default     = "root"
}

variable "mongodb_storage_size" {
  description = "Taille de stockage MongoDB"
  type        = string
  default     = "8Gi"
}
