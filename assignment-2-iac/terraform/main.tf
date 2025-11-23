# ============================================
# Assignment 2: Infrastructure as Code
# Provisions Azure Resource Group and Storage Account
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
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

  tags = merge(
    var.common_tags,
    {
      Purpose = "Assignment 2 - IaC Demo"
    }
  )
}

# ============================================
# Storage Account (ZRS Replication)
# ============================================

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Security settings
  min_tls_version                 = "TLS1_2" # ✅ Security best practice
  allow_nested_items_to_be_public = false    # ✅ Prevent public access

  tags = merge(
    var.common_tags,
    {
      Purpose = "Assignment 2 Storage"
    }
  )
}