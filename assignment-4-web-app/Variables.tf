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