terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --------------------------------
# Core infrastructure
# --------------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "asp" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = var.os_type
  sku_name            = var.sku_name
}

# --------------------------------
# Networking
# --------------------------------

resource "azurerm_virtual_network" "vn" {
  name                = var.azurerm_virtual_network
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_service_plan.asp.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "websn" {
  name                 = "${var.azurerm_subnet}-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "${var.azurerm_subnet}-web-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "aisn" {
  name                 = "${var.azurerm_subnet}-ai"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vslink" {
  name                  = var.azurerm_private_dns_zone_virtual_network_link
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vn.id
}

# --------------------------------
# Cognitive Service + Private Endpoint
# --------------------------------

resource "azurerm_cognitive_account" "ca" {
  name                  = var.cognitive_account_name
  location              = azurerm_service_plan.asp.location
  resource_group_name   = azurerm_resource_group.rg.name
  kind                  = var.ca_kind
  sku_name              = var.ca_sku
  custom_subdomain_name = "${var.cognitive_account_name}-subdomain"

  tags = {
    Acceptance = "Test"
  }
}

resource "azurerm_private_endpoint" "ca_pe" {
  name                = "${var.cognitive_account_name}-pe"
  location            = azurerm_service_plan.asp.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.aisn.id

  private_service_connection {
    name                           = "${var.cognitive_account_name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.ca.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.cognitive_account_name}-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }

  depends_on = [azurerm_cognitive_account.ca]
}

# --------------------------------
# Web App + VNet Integration
# --------------------------------

resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  https_only = true

  site_config {
    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = {
    AZ_ENDPOINT = azurerm_cognitive_account.ca.endpoint
    AZ_KEY      = azurerm_cognitive_account.ca.primary_access_key
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app_vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.websn.id
}
