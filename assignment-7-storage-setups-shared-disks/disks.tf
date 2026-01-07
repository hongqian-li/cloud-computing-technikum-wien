# ============================================
# Managed Disks
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
# Attach Disks to VMs (Step 3)
# ============================================

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}


# ============================================
# Step 4: Recovery Services Vault
# ============================================

resource "azurerm_recovery_services_vault" "main" {
  name                = "${var.prefix}-recovery-vault"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
}

# ============================================
# Step 5: Backup Policy (Daily at 22:00, 30-day retention)
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
# Step 5: Backup Protection for VMs
# ============================================

resource "azurerm_backup_protected_vm" "main" {
  count               = var.vm_count
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_linux_virtual_machine.main[count.index].id
  backup_policy_id    = azurerm_backup_policy_vm.main.id
}