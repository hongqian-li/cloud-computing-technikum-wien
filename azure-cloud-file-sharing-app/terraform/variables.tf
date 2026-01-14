# General variables
variable "project_name" {
  description = "Short name for the project"
  type        = string
  default     = "fileshare"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "norwayeast"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    owner       = "student-team"
    cost_center = "cloud-course"
  }
}

# Network
variable "vnet_address_space" {
  description = "Address space for VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_address_prefix" {
  description = "Address prefix for app subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Storage
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

variable "uploads_container_name" {
  description = "Name of uploads container"
  type        = string
  default     = "uploads"
}

variable "tfstate_container_name" {
  description = "Name of tfstate container"
  type        = string
  default     = "tfstate"
}

# SQL
variable "sql_admin_username" {
  description = "SQL admin username"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  default     = "P@ssw0rd123!ChangeMe"
  sensitive   = true
}

# App settings
variable "max_upload_bytes" {
  description = "Max file size in bytes"
  type        = number
  default     = 10485760
}

variable "allowed_file_types" {
  description = "Allowed file extensions"
  type        = list(string)
  default     = [".jpg", ".jpeg", ".png", ".gif", ".pdf"]
}