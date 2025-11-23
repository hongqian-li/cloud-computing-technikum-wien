# ============================================
# Assignment 6: Load Balancer Outputs
# ============================================

# ============================================
# Resource Group Outputs (Step 1)
# ============================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# ============================================
# Network Outputs (Step 1)
# ============================================

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "network_interface_ids" {
  description = "IDs of the network interfaces"
  value       = azurerm_network_interface.main[*].id
}

# ============================================
# VM Outputs (Step 1-2)
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
  value       = azurerm_linux_virtual_machine.main[*].private_ip_address
}

# ============================================
# Public IP Output (Step 3)
# ============================================

output "public_ip_address" {
  description = "The public IP address for accessing the load balancer"
  value       = azurerm_public_ip.main.ip_address
}

output "public_ip_id" {
  description = "ID of the public IP"
  value       = azurerm_public_ip.main.id
}

# ============================================
# Load Balancer Outputs (Step 4)
# ============================================

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = azurerm_lb.main.name
}

output "backend_pool_id" {
  description = "ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.id
}

# ============================================
# Health Probe Output (Step 5)
# ============================================

output "health_probe_id" {
  description = "ID of the health probe"
  value       = azurerm_lb_probe.main.id
}

# ============================================
# Load Balancing Rule Output (Step 6)
# ============================================

output "lb_rule_id" {
  description = "ID of the load balancing rule"
  value       = azurerm_lb_rule.main.id
}

# ============================================
# Summary Output
# ============================================

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    resource_group    = azurerm_resource_group.main.name
    location          = azurerm_resource_group.main.location
    public_ip         = azurerm_public_ip.main.ip_address
    load_balancer     = azurerm_lb.main.name
    vm_count          = var.vm_count
    vm_names          = azurerm_linux_virtual_machine.main[*].name
    access_url        = "http://${azurerm_public_ip.main.ip_address}"
  }
}