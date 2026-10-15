resource "azurerm_network_security_group" "servers" {
  name                = local.names.server_nsg
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name
  tags                = local.tags

  security_rule {
    name                       = "AllowRdpFromTrustedPublicIp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = local.server_rdp_source_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyRdpFromOtherSources"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "servers" {
  subnet_id                 = azurerm_subnet.servers.id
  network_security_group_id = azurerm_network_security_group.servers.id
}

resource "azurerm_network_interface" "server" {
  name                = local.names.server_nic
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.servers]
}

resource "azurerm_public_ip" "server" {
  name                = local.names.server_ip
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  tags                = local.tags
}

resource "azurerm_windows_virtual_machine" "server" {
  name                = local.names.server_vm
  computer_name       = "vm-${local.environment_code}-${local.instance}"
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [
    azurerm_network_interface.server.id,
  ]
  tags = local.tags

  os_disk {
    name                 = local.names.server_os_disk
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}