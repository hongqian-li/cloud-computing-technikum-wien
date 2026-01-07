# ============================================
# Assignment 8: Monitoring & Boot Diagnostics
# Creates: VNet, 2 VMs, Load Balancer, NSG, Storage, Backup, Boot Diagnostics
# Author: Hongqian Li, Bienias Kamil, Paradzik Marko, Zelimchanow Chamberg, Ramazanov Muslim
# Course: Cloud Computing - UAS Technikum Wien
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # ============================================
  # Remote State Backend Configuration
  # ============================================
  backend "azurerm" {
    resource_group_name  = "rg-test-deployment-dev"
    storage_account_name = "wi25x010terraformstate"
    container_name       = "tfstate"
    key                  = "assignment-8-monitoring.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# ============================================
# Resource Group
# ============================================

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "development"
    assignment  = "8"
  }
}

# ============================================
# Virtual Network
# ============================================

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "development"
    assignment  = "8"
  }
}

# ============================================
# Subnet
# ============================================

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefix
}

# ============================================
# Network Interfaces (2 VMs = 2 NICs)
# ============================================

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.prefix}-nic-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "development"
    assignment  = "8"
  }
}

# ============================================
# Storage Account for Boot Diagnostics (Assignment 8)
# ============================================

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "boot_diagnostics" {
  name                     = "${replace(var.prefix, "-", "")}bootdiag${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "development"
    assignment  = "8"
    purpose     = "boot-diagnostics"
  }
}

# ============================================
# Virtual Machines with Boot Diagnostics
# ============================================

resource "azurerm_linux_virtual_machine" "main" {
  count               = var.vm_count
  name                = "${var.prefix}-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "${var.prefix}-osdisk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Install Nginx automatically on boot
  custom_data = base64encode(file("${path.module}/scripts/install-nginx.sh"))

  # Enable boot diagnostics on the first VM (Assignment 8 requirement)
  boot_diagnostics {
    storage_account_uri = count.index == 0 ? azurerm_storage_account.boot_diagnostics.primary_blob_endpoint : null
  }

  tags = {
    environment      = "development"
    assignment       = "8"
    boot_diagnostics = count.index == 0 ? "enabled" : "disabled"
  }
}

# ============================================
# Managed Disks (Assignment 7)
# ============================================

resource "azurerm_managed_disk" "data_disk" {
  count                = var.vm_count
  name                 = "${var.prefix}-datadisk-${count.index + 1}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1024

  tags = {
    environment = "development"
    assignment  = "7"
  }
}

# ============================================
# Attach Disks to VMs
# ============================================

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}

# ============================================
# Public IP for Load Balancer
# ============================================

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = {
    environment = "development"
    assignment  = "8"
  }
}

# ============================================
# Load Balancer
# ============================================

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    environment = "development"
    assignment  = "8"
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackendPool"
}

# ============================================
# Health Probe
# ============================================

resource "azurerm_lb_probe" "main" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-http-probe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

# ============================================
# Load Balancing Rule
# ============================================

resource "azurerm_lb_rule" "main" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "${var.prefix}-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
  idle_timeout_in_minutes        = 4
  load_distribution              = "Default"
}

# ============================================
# Connect NICs to Backend Pool
# ============================================

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# ============================================
# Network Security Group
# ============================================

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "development"
    assignment  = "8"
  }
}

resource "azurerm_network_security_rule" "allow_lb_probe" {
  name                        = "Allow-LB-Probe"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# ============================================
# Recovery Services Vault (Assignment 7)
# ============================================

resource "azurerm_recovery_services_vault" "main" {
  name                = "${var.prefix}-recovery-vault"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  soft_delete_enabled = true

  tags = {
    environment = "development"
    assignment  = "7"
  }
}

# ============================================
# Backup Policy
# ============================================

resource "azurerm_backup_policy_vm" "main" {
  name                = "${var.prefix}-backup-policy"
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = "22:00"
  }

  retention_daily {
    count = 30
  }
}

# ============================================
# Backup Protection for VMs
# ============================================

resource "azurerm_backup_protected_vm" "main" {
  count               = var.vm_count
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_linux_virtual_machine.main[count.index].id
  backup_policy_id    = azurerm_backup_policy_vm.main.id
}