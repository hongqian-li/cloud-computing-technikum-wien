# ============================================
# Phase 1: Resource Group and Network
# ============================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name_prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# ============================================
# Phase 2: Subnets and Network Security Group
# ============================================

# Subnet for Application Gateway
resource "azurerm_subnet" "subnet_appgw" {
  name                 = "${local.name_prefix}-snet-appgw"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Subnet for App Service with delegation
resource "azurerm_subnet" "subnet_app" {
  name                 = "${local.name_prefix}-snet-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_app_address_prefix]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "subnet_pe" {
  name                 = "${local.name_prefix}-snet-pe"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group for App Subnet
resource "azurerm_network_security_group" "nsg_app" {
  name                = "${local.name_prefix}-nsg-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_https_out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_sql_out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "Sql"
  }

  tags = var.tags
}

# Associate NSG with App Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_app_nsg" {
  subnet_id                 = azurerm_subnet.subnet_app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

# ============================================
# Phase 3: Storage Account and Containers
# ============================================

# Storage Account - for uploads and tfstate
resource "azurerm_storage_account" "sa" {
  name                     = substr(replace(lower("${local.name_prefix}sa"), "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"

  public_network_access_enabled   = true  #temporarily enabled for testing
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true

  tags = var.tags
}

# Storage Container - uploads
resource "azurerm_storage_container" "uploads" {
  name                  = var.uploads_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# Storage Container - tfstate
resource "azurerm_storage_container" "tfstate" {
  name                  = var.tfstate_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}