# ============================================
# Public IP Output (Step 3)
# ============================================

output "public_ip_address" {
  description = "The public IP address for accessing the load balancer"
  value       = azurerm_public_ip.main.ip_address
}
