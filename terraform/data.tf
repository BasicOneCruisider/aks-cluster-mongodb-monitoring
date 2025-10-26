# ================================================================
# DATA SOURCES
# ================================================================

# Référence au workspace Log Analytics existant
data "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_resource_group
}
