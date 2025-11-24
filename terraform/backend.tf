terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-devops-rg" 
    storage_account_name = "webpagetfstate"
    container_name       = "tfstate"
    key                  = "resume-repo.terraform.tfstate"
  }
}