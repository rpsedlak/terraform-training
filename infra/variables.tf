variable "environment" {
  description = "Deployment environment used to derive resource names."
  type        = string

  validation {
    condition     = contains(["development", "testing", "production"], var.environment)
    error_message = "environment must be development, testing, or production."
  }
}

variable "vm_size" {
  description = "VM size for every environment: Standard_D2ds_v6 by default, or a B-series override with at least two vCPUs."
  type        = string
  default     = "Standard_D2ds_v6"

  validation {
    condition     = var.vm_size == "Standard_D2ds_v6" || can(regex("^Standard_B(2|[3-9]|[1-9][0-9]+)[A-Za-z0-9_]*$", var.vm_size))
    error_message = "vm_size must be Standard_D2ds_v6 or a B-series SKU with at least two vCPUs."
  }
}

variable "vm_admin_username" {
  description = "Local Windows administrator account name for the server VM."
  type        = string

  validation {
    condition     = length(var.vm_admin_username) >= 1 && length(var.vm_admin_username) <= 20
    error_message = "vm_admin_username must be between 1 and 20 characters."
  }
}

variable "vm_admin_password" {
  description = "Local Windows administrator password for the server VM; provide through a secret input."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.vm_admin_password) >= 12
    error_message = "vm_admin_password must contain at least 12 characters."
  }
}