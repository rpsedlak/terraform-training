mock_provider "azurerm" {}

override_resource {
  target = azurerm_subnet.bastion
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/AzureBastionSubnet"
  }
  override_during = plan
}

override_resource {
  target = azurerm_subnet.servers
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/snet-servers"
  }
  override_during = plan
}

override_resource {
  target = azurerm_public_ip.bastion
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/test-bastion-ip"
  }
  override_during = plan
}

override_resource {
  target = azurerm_network_security_group.servers
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-server-nsg"
  }
  override_during = plan
}

override_resource {
  target = azurerm_network_interface.server
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/test-server-nic"
  }
  override_during = plan
}

run "development_names" {
  command = plan

  variables {
    environment       = "development"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  assert {
    condition     = local.environment_code == "d"
    error_message = "development must use the d environment code."
  }

  assert {
    condition     = azurerm_resource_group.environment.name == "rg-terraform-training-d-eastus-001"
    error_message = "development resource names must use the approved naming pattern."
  }

  assert {
    condition = (
      local.names.vnet == "vnet-terraform-training-d-eastus-001" &&
      local.names.bastion == "bas-terraform-training-d-eastus-001" &&
      local.names.bastion_ip == "pip-terraform-training-d-eastus-001" &&
      local.names.server_nsg == "nsg-terraform-training-d-eastus-001" &&
      local.names.server_nic == "nic-terraform-training-d-eastus-001" &&
      local.names.server_os_disk == "disk-terraform-training-d-eastus-001"
    )
    error_message = "all Azure resource names must follow the approved environment pattern."
  }

  assert {
    condition     = azurerm_virtual_network.environment.address_space == toset(["10.20.0.0/22"])
    error_message = "the environment VNet must use the approved /22 address space."
  }

  assert {
    condition     = local.bastion_subnet_cidr == "10.20.0.0/26" && local.server_subnet_cidr == "10.20.1.0/24"
    error_message = "Bastion and server subnets must use their approved CIDR ranges."
  }

  assert {
    condition = (
      cidrsubnet(local.vnet_cidr, 4, 0) == local.bastion_subnet_cidr &&
      cidrsubnet(local.vnet_cidr, 2, 1) == local.server_subnet_cidr
    )
    error_message = "subnets must be contained in the VNet and must not overlap."
  }

  assert {
    condition     = azurerm_bastion_host.environment.sku == "Basic" && azurerm_public_ip.bastion.sku == "Standard" && azurerm_public_ip.bastion.allocation_method == "Static"
    error_message = "Bastion must use Basic SKU and a Standard static public IP."
  }

  assert {
    condition = (
      azurerm_bastion_host.environment.ip_configuration[0].subnet_id == azurerm_subnet.bastion.id &&
      azurerm_bastion_host.environment.ip_configuration[0].public_ip_address_id == azurerm_public_ip.bastion.id
    )
    error_message = "Bastion must be attached to AzureBastionSubnet and its Standard public IP."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.server.size == "Standard_B2s_v2"
    error_message = "the VM must default to Standard_B2s_v2."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.server.source_image_reference[0].sku == "2022-datacenter-azure-edition"
    error_message = "the VM must use Windows Server 2022 Datacenter Azure Edition."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.server.os_disk[0].storage_account_type == "Premium_LRS" && azurerm_windows_virtual_machine.server.os_disk[0].disk_size_gb == 128
    error_message = "the VM must use a 128 GiB Premium SSD P10 OS disk."
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.servers.security_rule : rule.source_address_prefix == "10.20.0.0/26" && rule.destination_port_range == "3389" && rule.access == "Allow"])
    error_message = "RDP must be allowed from the Bastion subnet."
  }

  assert {
    condition     = anytrue([for rule in azurerm_network_security_group.servers.security_rule : rule.source_address_prefix == "*" && rule.destination_port_range == "3389" && rule.access == "Deny"])
    error_message = "RDP from every other source must be denied."
  }

  assert {
    condition = (
      azurerm_network_interface.server.ip_configuration[0].subnet_id == azurerm_subnet.servers.id &&
      azurerm_subnet_network_security_group_association.servers.subnet_id == azurerm_subnet.servers.id &&
      azurerm_subnet_network_security_group_association.servers.network_security_group_id == azurerm_network_security_group.servers.id
    )
    error_message = "the server NIC and RDP security group must be attached to the servers subnet."
  }

  assert {
    condition     = contains(azurerm_windows_virtual_machine.server.network_interface_ids, azurerm_network_interface.server.id)
    error_message = "the server VM must use the private server NIC."
  }
}

run "testing_code" {
  command = plan

  variables {
    environment       = "testing"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  assert {
    condition     = local.environment_code == "t"
    error_message = "testing must use the t environment code."
  }

  assert {
    condition     = local.names.server_vm == "vm-terraform-training-t-eastus-001"
    error_message = "testing VM names must use the t environment code."
  }
}

run "production_code" {
  command = plan

  variables {
    environment       = "production"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  assert {
    condition     = local.environment_code == "p"
    error_message = "production must use the p environment code."
  }

  assert {
    condition     = local.names.server_vm == "vm-terraform-training-p-eastus-001"
    error_message = "production VM names must use the p environment code."
  }
}

run "reject_invalid_environment" {
  command = plan

  variables {
    environment       = "staging"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  expect_failures = [var.environment]
}

run "reject_undersized_vm" {
  command = plan

  variables {
    environment       = "development"
    vm_size           = "Standard_B1s"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  expect_failures = [var.vm_size]
}

run "accept_valid_b_series_override" {
  command = plan

  variables {
    environment       = "development"
    vm_size           = "Standard_B4ms"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  assert {
    condition     = azurerm_windows_virtual_machine.server.size == "Standard_B4ms"
    error_message = "a B-series override with at least two vCPUs must be accepted."
  }
}

run "reject_non_b_series_vm" {
  command = plan

  variables {
    environment       = "development"
    vm_size           = "Standard_D2s_v5"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  expect_failures = [var.vm_size]
}

run "reject_short_admin_password" {
  command = plan

  variables {
    environment       = "development"
    vm_admin_username = "vmadmin"
    vm_admin_password = "short"
  }

  expect_failures = [var.vm_admin_password]
}

run "reject_empty_admin_username" {
  command = plan

  variables {
    environment       = "development"
    vm_admin_username = ""
    vm_admin_password = "example-only-password-123"
  }

  expect_failures = [var.vm_admin_username]
}

run "reject_long_admin_username" {
  command = plan

  variables {
    environment       = "development"
    vm_admin_username = "thisusernameisover20chars"
    vm_admin_password = "example-only-password-123"
  }

  expect_failures = [var.vm_admin_username]
}

run "server_nic_has_no_public_ip" {
  command = plan

  variables {
    environment       = "development"
    vm_admin_username = "vmadmin"
    vm_admin_password = "example-only-password-123"
  }

  assert {
    condition     = azurerm_network_interface.server.ip_configuration[0].public_ip_address_id == null
    error_message = "the server network interface must not have a public IP association."
  }
}