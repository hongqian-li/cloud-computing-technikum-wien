# ============================================
# Variable Definitions
# ============================================

variable "resource_group_name" { # ✅ Consistent naming
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-assignment2-iac" # ✅ Generic, not personal

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "norwayeast"

  validation {
    condition     = contains(["austriaeast", "norwayeast", "italynorth"], var.location)
    error_message = "Location must be austriaeast, norwayeast, or italynorth as per assignment requirements."
  }
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account (must be globally unique, 3-24 chars, lowercase alphanumeric)"
  type        = string
  default     = "stassignment2iac" # ✅ Generic, not personal

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "account_tier" {
  description = "Performance tier of the storage account"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Replication type for the storage account (ZRS = Zone-Redundant Storage)"
  type        = string
  default     = "ZRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Assignment  = "2-IaC"
    ManagedBy   = "Terraform"
    Course      = "Cloud-Computing"
  }
}