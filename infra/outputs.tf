output "resource_group_name" {
  description = "Name of the resource group containing the environment."
  value       = azurerm_resource_group.environment.name
}

output "virtual_network_id" {
  description = "Resource ID of the environment virtual network."
  value       = azurerm_virtual_network.environment.id
}

output "server_public_ip_address" {
  description = "Public IPv4 address for direct RDP from 69.244.159.36/32."
  value       = azurerm_public_ip.server.ip_address
}

output "server_private_ip_address" {
  description = "Private IP address of the server VM."
  value       = azurerm_network_interface.server.private_ip_address
}