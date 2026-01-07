variable "resource_group_name" {
  type    = string
  default = "rg-clco-demo-group-3"
}

variable "location" {
  type    = string
  default = "norwayeast"
}

variable "service_plan_name" {
  type    = string
  default = "asp-clco-demo-group-3"
}

variable "web_app_name" {
  type    = string
  default = "app-clco-demo-group-3"
}

variable "cognitive_account_name" {
  type    = string
  default = "ca-clco-demo-group-3"
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "sku_name" {
  type    = string
  default = "B1"
}

variable "python_version" {
  type    = string
  default = "3.11"
}

variable "ca_kind" {
  type    = string
  default = "TextAnalytics"
}

variable "ca_sku" {
  type    = string
  default = "S"
}

variable "azurerm_virtual_network" {
  type    = string
  default = "vn-clco-demo-group-3"
}

variable "azurerm_subnet" {
  type    = string
  default = "sn-clco-demo-group-3"
}

variable "azurerm_private_dns_zone_virtual_network_link" {
  type    = string
  default = "vn-link-clco-demo-group-3"
}
