output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.sa.name
}

output "uploads_container_name" {
  description = "Uploads container name"
  value       = azurerm_storage_container.uploads.name
}

output "tfstate_container_name" {
  description = "Tfstate container name"
  value       = azurerm_storage_container.tfstate.name
}