output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "web_app_url" {
  description = "Web app URL"
  value       = azurerm_linux_web_app.app.default_hostname
}

output "app_gateway_public_ip" {
  description = "Application Gateway public IP"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.sa.name
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "uploads_container_name" {
  description = "Uploads container name"
  value       = azurerm_storage_container.uploads.name
}

output "tfstate_container_name" {
  description = "Tfstate container name"
  value       = azurerm_storage_container.tfstate.name
}