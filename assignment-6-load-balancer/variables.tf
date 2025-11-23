# ============================================
# Variables for Assignment 6
# ============================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-loadbalancer-assignment6"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "norwayeast"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "lb-a6"
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
  default     = "Standard_B1s" # vCPUs: 1, RAM: 1 GB, Temp storage: 4 GB and cheaper than "Standard_F2"
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

variable "allocation_method" {
  description = "Allocation method for Public IP"
  type        = string
  default     = "Static"
}

variable "sku_public_ip" {
  description = "SKU for Public IP"
  type        = string
  default     = "Standard"
}

variable "public_ip_zones" {
  description = "Availability zones for Public IP"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "azurerm_lb_sku" {
  description = "SKU for Load Balancer"
  type        = string
  default     = "Standard"
}

variable "lb_outbound_rule_protocol" {
  description = "Protocol for Load Balancer outbound rule"
  type        = string
  default     = "All"
}

variable "frontend_ip_configuration_name" {
  description = "Frontend IP configuration name for Load Balancer"
  type        = string
  default     = "PublicIPAddress"
}

variable "lb_backend_address_pool_name" {
  description = "Backend address pool name for Load Balancer"
  type        = string
  default     = "BackendPool"
}

variable "lb_outbound_rule_name" {
  description = "Name for Load Balancer outbound rule"
  type        = string
  default     = "OutboundRule"
  
}