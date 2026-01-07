# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configure the Azure connection
provider "azurerm" {
  features {}
}

# Create the main resource group to hold everything
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Make service plan for the app
resource "azurerm_service_plan" "asp" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = var.os_type
  sku_name            = var.sku_name
}

# Create the actual web app that will run our Flask application
resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  # Use Python 3.11
  site_config {
    application_stack {
      python_version = var.python_version
    }
  }
}