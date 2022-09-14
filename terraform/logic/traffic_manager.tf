

resource "azurerm_traffic_manager_profile" "traffic_manager" {
  name                   = "${local.naming_convention}-tf"
  resource_group_name    = azurerm_resource_group.resource_group.name
  traffic_routing_method = var.traffic_routing_method

  dns_config {
    relative_name = "tf-adp-lb"
    ttl           = 100
  }

  //Pasar eso a variables
  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }


}

resource "azurerm_traffic_manager_endpoint" "endpoint1" {
 // provider               = azurerm.tfprovider
  name               = "${local.naming_convention}-endpoint-tf"
 // profile_id         = azurerm_traffic_manager_profile.traffic_manager.id
//  target_resource_id = azurerm_public_ip.public_ip_lb.id
  resource_group_name = azurerm_resource_group.resource_group.name
  profile_name         = azurerm_traffic_manager_profile.traffic_manager.name
  type              = "azureEndpoints"
  weight             = 100
  target_resource_id = "/subscriptions/8978be07-1d78-42ca-9a5a-86f478954e58/resourceGroups/${azurerm_resource_group.resource_group.name}/providers/Microsoft.Network/publicIPAddresses/${azurerm_public_ip.public_ip_lb.name}"
}

