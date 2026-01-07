variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "stwi25x010assignment03"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "norwayeast"
}

variable "azurerm_resource_group" {
  description = "The name of the Azure resource group"
  type        = string
  default     = "wi25x010-assignment03"
}

variable "account_replication_type" {
  description = "The replication type for the storage account"
  type        = string
  default     = "ZRS"
}

variable "budget_name" {
  description = "Name of the subscription budget"
  type        = string
  default     = "budget"
}

variable "budget_amount" {
  description = "The total budget amount"
  type        = number
  default     = 1000
}

variable "budget_start_date" {
  description = "Start date of the budget period"
  type        = string
  default     = "2025-11-01T00:00:00Z"
}

variable "budget_end_date" {
  description = "End date of the budget period"
  type        = string
  default     = "2026-11-01T00:00:00Z"
}

variable "notification_emails" {
  description = "Emails to notify when budget threshold is met"
  type        = list(string)
  default     = ["lucas.lhqcd@gmail.com", "wi25x010@technikum-wien.at"]
}

variable "notification_threshold" {
  description = "Threshold percentage for notification"
  type        = number
  default     = 90.0
}

variable "notification_operator" {
  description = "Operator for threshold comparison"
  type        = string
  default     = "GreaterThan"
}
