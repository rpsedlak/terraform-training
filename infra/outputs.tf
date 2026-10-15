output "resource_group_name" {
  description = "Name of the resource group containing the environment."
  value       = azurerm_resource_group.environment.name
}

output "virtual_network_id" {
  description = "Resource ID of the environment virtual network."
  value       = azurerm_virtual_network.environment.id
}

output "bastion_id" {
  description = "Resource ID of the Azure Bastion host."
  value       = azurerm_bastion_host.environment.id
}

output "server_private_ip_address" {
  description = "Private IP address of the server VM."
  value       = azurerm_network_interface.server.private_ip_address
}