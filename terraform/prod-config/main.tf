terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}


module "logic" {
  source = "../logic"
  environment = "prod"
  location = "East US"
  service = "distri"
}