# ============================================
# Variables for Assignment 6
# ============================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-storage-assignment7"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "norwayeast"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "sd-a7"
}

variable "vnet_address_space" {
  description = "Address space for virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "vm_count" {
  description = "Number of VMs"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of VMs"
  type        = string
  default     = "Standard_F2s_v2" #(2 vcpus, 4 GiB memory)
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = null
}