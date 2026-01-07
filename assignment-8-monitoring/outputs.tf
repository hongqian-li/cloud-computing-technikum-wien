# ============================================
# Assignment 8: Monitoring Outputs
# ============================================

# ============================================
# Network Outputs
# ============================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.main.name
}

# ============================================
# VM Outputs
# ============================================

output "vm_names" {
  description = "Names of the virtual machines"
  value       = azurerm_linux_virtual_machine.main[*].name
}

output "vm_ids" {
  description = "IDs of the virtual machines"
  value       = azurerm_linux_virtual_machine.main[*].id
}

output "vm_private_ips" {
  description = "Private IP addresses of the VMs"
  value       = azurerm_network_interface.main[*].private_ip_address
}

# ============================================
# Load Balancer Outputs
# ============================================

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.main.ip_address
}

output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = azurerm_lb.main.name
}

output "load_balancer_url" {
  description = "URL to access the load balanced application"
  value       = "http://${azurerm_public_ip.main.ip_address}"
}

# ============================================
# Managed Disk Outputs
# ============================================

output "managed_disk_ids" {
  description = "IDs of the managed disks"
  value       = azurerm_managed_disk.data_disk[*].id
}

output "managed_disk_names" {
  description = "Names of the managed disks"
  value       = azurerm_managed_disk.data_disk[*].name
}

# ============================================
# Recovery Services Vault Outputs
# ============================================

output "recovery_vault_name" {
  description = "Name of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.main.name
}

output "recovery_vault_id" {
  description = "ID of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.main.id
}

output "backup_policy_name" {
  description = "Name of the backup policy"
  value       = azurerm_backup_policy_vm.main.name
}

output "backup_policy_id" {
  description = "ID of the backup policy"
  value       = azurerm_backup_policy_vm.main.id
}

output "backup_protected_vm_ids" {
  description = "IDs of backup protected VMs"
  value       = azurerm_backup_protected_vm.main[*].id
}

# ============================================
# Boot Diagnostics Outputs (Assignment 8)
# ============================================

output "boot_diagnostics_storage_account" {
  description = "Storage account used for boot diagnostics"
  value       = azurerm_storage_account.boot_diagnostics.name
}

output "boot_diagnostics_storage_uri" {
  description = "Boot diagnostics storage URI"
  value       = azurerm_storage_account.boot_diagnostics.primary_blob_endpoint
}

output "boot_diagnostics_enabled_vm" {
  description = "VM with boot diagnostics enabled"
  value       = azurerm_linux_virtual_machine.main[0].name
}

output "boot_diagnostics_enabled_vm_id" {
  description = "ID of VM with boot diagnostics enabled"
  value       = azurerm_linux_virtual_machine.main[0].id
}

# ============================================
# Summary Output
# ============================================

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    resource_group           = azurerm_resource_group.main.name
    location                 = azurerm_resource_group.main.location
    vm_count                 = var.vm_count
    load_balancer_ip         = azurerm_public_ip.main.ip_address
    load_balancer_url        = "http://${azurerm_public_ip.main.ip_address}"
    boot_diagnostics_vm      = azurerm_linux_virtual_machine.main[0].name
    boot_diagnostics_storage = azurerm_storage_account.boot_diagnostics.name
    backup_enabled           = true
    managed_disks            = length(azurerm_managed_disk.data_disk)
  }
}