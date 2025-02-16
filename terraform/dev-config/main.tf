terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


module "logic" {
  source      = "../logic"
  environment = "dev"
  location    = "East US"
  service     = "distri"
}