# ================================================================
# INFRASTRUCTURE RESOURCES - Resource Group & Network
# ================================================================

# Créer le groupe de ressources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Workshop"
    Project     = "K8s-Learning"
    ManagedBy   = "Terraform"
    Backup      = "True"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
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

# Créer le sous-réseau pour AKS
resource "azurerm_subnet" "default" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.1.0/24"]
}
