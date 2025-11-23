# ============================================
# Public IP Output (Step 3)
# ============================================

output "public_ip_address" {
  description = "The public IP address for accessing the load balancer"
  value       = azurerm_public_ip.main.ip_address
}

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "backend_pool_id" {
  description = "ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.id
}

output "lb_rule_id" {
  description = "ID of the load balancing rule"
  value       = azurerm_lb_rule.main.id
}