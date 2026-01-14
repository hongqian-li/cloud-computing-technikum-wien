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

  public_network_access_enabled   = true # Set to true to allow private endpoints  #temporarily
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true

  # Temporarily commented out to simplify initial deployment
  #network_rules {
  #  default_action = "Deny"
  #  bypass         = ["AzureServices"]
  #}
  
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

# ============================================
# Phase 4: Private DNS Zones and Private Endpoints
# ============================================

# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Private DNS Zone for SQL Database
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Link Blob DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_vnet_link" {
  name                  = "${local.name_prefix}-blob-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  tags                  = var.tags
}

# Link SQL DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql_vnet_link" {
  name                  = "${local.name_prefix}-sql-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  tags                  = var.tags
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${local.name_prefix}-storage-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet_pe.id

  private_service_connection {
    name                           = "${local.name_prefix}-storage-psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_dns.id]
  }

  tags = var.tags
}

# ============================================
# Phase 5: SQL Server, Database and Private Endpoint
# ============================================

# SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "${local.name_prefix}-sqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = false

  tags = var.tags
}

# SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name      = "${local.name_prefix}-sqldb"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic"

  tags = var.tags
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${local.name_prefix}-sql-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet_pe.id

  private_service_connection {
    name                           = "${local.name_prefix}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }

  tags = var.tags
}

# ============================================
# Phase 6: App Service Plan, Application Insights, and Web App
# ============================================

# App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "${local.name_prefix}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "${local.name_prefix}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = var.tags
  
  lifecycle {
    ignore_changes = [workspace_id]
  }
}

# Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "${local.name_prefix}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  https_only = true

  site_config {
    always_on         = true
    ftps_state        = "Disabled"
    minimum_tls_version = "1.2"
    vnet_route_all_enabled = true

    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "STORAGE_CONNECTION_STRING"             = azurerm_storage_account.sa.primary_connection_string
    "STORAGE_ACCOUNT_NAME"                  = azurerm_storage_account.sa.name
    "STORAGE_CONTAINER_UPLOAD"              = azurerm_storage_container.uploads.name
    "SQL_SERVER_FQDN"                       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    "SQL_DATABASE"                          = azurerm_mssql_database.sql_db.name
    "SQL_USERNAME"                          = var.sql_admin_username
    "SQL_PASSWORD"                          = var.sql_admin_password
    "MAX_UPLOAD_BYTES"                      = tostring(var.max_upload_bytes)
    "ALLOWED_FILE_TYPES"                    = join(",", var.allowed_file_types)
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "SCM_DO_BUILD_DURING_DEPLOYMENT"        = "true"
  }

  tags = var.tags
}

# VNet Integration
resource "azurerm_app_service_virtual_network_swift_connection" "app_vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.subnet_app.id
}


# ============================================
# Phase 7: Application Gateway and Public IP
# ============================================

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = "${local.name_prefix}-appgw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "appgw" {
  name                = "${local.name_prefix}-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name  = "webapp-backend"
    fqdns = [azurerm_linux_web_app.app.default_hostname]
  }

  backend_http_settings {
    name                                = "webapp-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "webapp-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "webapp-rule"
    rule_type                  = "Basic"
    http_listener_name         = "webapp-listener"
    backend_address_pool_name  = "webapp-backend"
    backend_http_settings_name = "webapp-http-settings"
    priority                   = 100
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"  #Updated TLS policy
  }

  tags = var.tags
}