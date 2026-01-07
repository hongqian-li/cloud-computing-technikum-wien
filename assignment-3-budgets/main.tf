data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.azurerm_resource_group
  location = var.location
}

provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_replication_type = var.account_replication_type
  account_tier             = "Standard"

  tags = {
    environment = "staging"
    student     = "wi25x010"
    assignment  = "03"
  }
}

resource "azurerm_consumption_budget_subscription" "budget" {
  name            = var.budget_name
  subscription_id = data.azurerm_subscription.current.id

  amount     = var.budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
    end_date   = var.budget_end_date
  }

  notification {
    enabled        = true
    threshold      = var.notification_threshold
    operator       = var.notification_operator
    threshold_type = "Actual"
    contact_emails = var.notification_emails
  }

  notification {
    enabled        = true
    threshold      = var.notification_threshold
    operator       = var.notification_operator
    threshold_type = "Forecasted"
    contact_emails = var.notification_emails
  }
}