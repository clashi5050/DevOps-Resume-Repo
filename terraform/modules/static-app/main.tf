resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.app_name}-prod"
  location = var.location
}

# 1. Monitoring: Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.app_name}-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# 2. Hosting: Azure Static Web App (SWA)
resource "azurerm_static_web_app" "resume_swa" {
  name                = "swa-${var.app_name}-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Link to your GitHub repo and main branch
  # The token is passed via the GitHub Action, not here directly for the free tier.
  # For first-time provisioning, we link the repo and let the CI/CD handle the rest.
  # (Note: For this module, you will need corresponding variables.tf and outputs.tf)
}