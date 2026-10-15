resource "azurerm_public_ip" "bastion" {
  name                = local.names.bastion_ip
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  tags                = local.tags
}

resource "azurerm_bastion_host" "environment" {
  name                = local.names.bastion
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name
  sku                 = "Basic"
  tags                = local.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}