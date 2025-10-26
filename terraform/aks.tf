# ================================================================
# AKS CLUSTER CONFIGURATION
# ================================================================

# Cluster AKS Principal
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

    tags = {
      Role = "System"
    }
  }

  # Identité managée
  identity {
    type = "SystemAssigned"
  }

  # Configuration réseau Azure CNI
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

  # Addons Azure
  azure_policy_enabled = true

  # Azure Monitor - OMS Agent
  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  }

  # OIDC Issuer pour Workload Identity
  oidc_issuer_enabled = true

  # Azure Monitor Metrics
  monitor_metrics {}

  # Configuration du stockage
  storage_profile {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  # Gestion des maintenances
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [2, 3, 4]
    }
  }

  tags = azurerm_resource_group.main.tags
}
