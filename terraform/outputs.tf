# ================================================================
# OUTPUTS - AKS Cluster Information
# ================================================================

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

output "resource_group_name" {
  description = "Nom du groupe de ressources"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID du réseau virtuel"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "ID du sous-réseau"
  value       = azurerm_subnet.default.id
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

output "mongodb_namespace" {
  description = "Namespace MongoDB"
  value       = kubernetes_namespace.ratingapp.metadata[0].name
}
