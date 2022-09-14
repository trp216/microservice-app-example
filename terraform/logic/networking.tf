terraform {
  required_providers{
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.71.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location_formatted = replace(lower(var.location), " ", "")
  naming_convention  = "${var.environment}-${var.service}-${local.location_formatted}"
}


# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  #coalesce hace lo de if ___ is null then ___
  name     = "${local.naming_convention}-rg"
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.naming_convention}-vnet"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_backend" {
  name                 = "${local.naming_convention}-backend-sn"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]


}

resource "azurerm_subnet" "subnet_frontend" {
  name                 = "${local.naming_convention}-frontend-sn"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]


}

resource "azurerm_subnet" "subnet_app_gateway" {
  name                 = "${local.naming_convention}-app-gateway-sn"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]


}
