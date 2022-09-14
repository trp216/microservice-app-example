resource "azurerm_availability_set" "front_availability" {
  name                = "${local.naming_convention}-frontend-savs"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name


}

resource "azurerm_network_interface" "front_nic" {
  name                = "${local.naming_convention}-frontend-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.subnet_frontend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.front_public_ip.id
  }
}

resource "azurerm_public_ip" "front_public_ip" {
  name                = "${local.naming_convention}-front-public-ip"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "front_vm" {
  name                            = "${local.naming_convention}-vm"
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Tomate123*"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.front_nic.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "public_ip_lb" {
  name                = "${local.naming_convention}-lb-public-ip"
  domain_name_label   = "lbipadp"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "load_balancer" {
  name                = "${local.naming_convention}-lb"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip_lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool_lb" {
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "backend_association" {
  network_interface_id    = azurerm_network_interface.front_nic.id
  ip_configuration_name   = "public"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool_lb.id
}

resource "azurerm_network_security_group" "vm_sec_group" {
  name                = "${local.naming_convention}-vm-sec-group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "test123"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "association_vm_secgroup" {
  network_interface_id      = azurerm_network_interface.front_nic.id
  network_security_group_id = azurerm_network_security_group.vm_sec_group.id
}
