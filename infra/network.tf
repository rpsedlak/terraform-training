resource "azurerm_resource_group" "environment" {
  name     = local.names.resource_group
  location = local.location
  tags     = local.tags

}

resource "azurerm_virtual_network" "environment" {
  name                = local.names.vnet
  address_space       = [local.vnet_cidr]
  location            = azurerm_resource_group.environment.location
  resource_group_name = azurerm_resource_group.environment.name
  tags                = local.tags
}

resource "azurerm_subnet" "servers" {
  name                 = local.names.server_subnet
  resource_group_name  = azurerm_resource_group.environment.name
  virtual_network_name = azurerm_virtual_network.environment.name
  address_prefixes     = [local.server_subnet_cidr]
}