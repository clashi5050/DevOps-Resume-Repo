terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "static_app_module" {
  source = "./modules/static-app"
  location = var.location
  app_name = var.app_name
}
