variable "environment" {
  description = "Deployment environment used to derive resource names."
  type        = string

  validation {
    condition     = contains(["development", "testing", "production"], var.environment)
    error_message = "environment must be development, testing, or production."
  }
}

variable "vm_size" {
  description = "B-series VM size with at least two vCPUs."
  type        = string
  default     = "Standard_B2s_v2"

  validation {
    condition     = can(regex("^Standard_B(2|[3-9]|[1-9][0-9]+)[A-Za-z0-9_]*$", var.vm_size))
    error_message = "vm_size must be a B-series SKU with at least two vCPUs."
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