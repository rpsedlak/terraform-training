locals {
  location = "eastus"
  workload = "terraform-training"
  instance = "001"

  environment_codes = {
    development = "d"
    testing     = "t"
    production  = "p"
  }

  environment_code = local.environment_codes[var.environment]

  vnet_cidr              = "10.20.0.0/22"
  server_subnet_cidr     = "10.20.1.0/24"
  server_rdp_source_cidr = "69.244.159.36/32"

  names = {
    resource_group = "rg-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
    vnet           = "vnet-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
    server_subnet  = "snet-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
    server_ip      = "pip-server-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
    server_nsg     = "nsg-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
    server_vm      = "vm-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
    server_nic     = "nic-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
    server_os_disk = "disk-${local.workload}-${local.environment_code}-${local.location}-${local.instance}"
  }

  tags = {
    environment = var.environment
    workload    = local.workload
    managed_by  = "terraform"
  }
}