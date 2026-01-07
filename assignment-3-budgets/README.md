# Azure Budget Management with Terraform

This is my assignment project for learning how to create and manage Azure budgets using Terraform. The goal was to understand how companies control cloud spending through automated budget monitoring.

## About This Project

As part of my Cloud Computing course at UAS Technikum Wien, I learned to set up budget alerts for Azure subscriptions. This helps prevent unexpected costs by sending notifications when spending reaches certain thresholds.

## What I Built

- A monthly budget that tracks Azure subscription spending
- Email notifications when costs reach 90% of the budget
- Alerts for both actual spending and forecasted costs
- One-year budget period (November 2025 - November 2026)

## Files in This Project

- `main.tf` - Main configuration with budget and resource group setup
- `variables.tf` - Variable definitions for customizable values
- `README.md` - This documentation

## Technologies Used

- Terraform (for infrastructure as code)
- Azure Cost Management
- Azure Consumption Budgets

## How to Use

### Prerequisites
- Azure account with an active subscription
- Terraform installed on your computer
- Azure CLI installed

### Steps to Deploy

1. Login to Azure:
   ```bash
   az login
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Check what will be created:
   ```bash
   terraform plan
   ```

4. Create the budget:
   ```bash
   terraform apply
   ```

5. When done, remove everything:
   ```bash
   terraform destroy
   ```

## Configuration

You can change these settings in `variables.tf`:

- **budget_amount**: How much money to budget (default: 1000)
- **notification_threshold**: When to send alerts (default: 90%)
- **notification_emails**: Where to send alerts
- **budget_start_date**: When budget starts (default: November 2025)
- **budget_end_date**: When budget expires (default: November 2026)

## What I Learned

### Why Cloud Budgets Matter

From this assignment, I learned that budgets are important for:
- Preventing surprise bills from cloud services
- Helping teams stay within their allocated costs
- Getting early warnings before spending too much
- Making sure cloud resources don't waste money

### Who Should Get Notifications

Based on my research, budget alerts should go to:
- The team leader or project manager
- DevOps engineers who manage the infrastructure
- Finance department (for larger budgets)
- Sometimes the whole development team

### Terraform vs Azure Portal

I found that using Terraform has advantages:
- Can recreate the same budget setup easily
- Changes are tracked in Git
- Good for setting up multiple similar budgets
- Better for team collaboration

But the Azure Portal is useful when:
- You just need to create one budget quickly
- You're still learning and want to see the interface
- Non-technical people need to adjust budgets

## Assignment Details

This project was completed for Assignment 3 of the Cloud Computing & Infrastructure course at UAS Technikum Wien (Winter Semester 2025). The assignment focused on understanding Azure cost management and practicing Terraform automation.

## Problems I Encountered

- Understanding the date format for Terraform (needed ISO 8601 format)
- Making sure both actual and forecasted notifications were configured
- Testing the budget without actually spending money (had to rely on validation)

## Future Improvements

If I continue working on this, I could:
- Add multiple notification thresholds (like 50%, 75%, 90%)
- Create separate budgets for different resource groups
- Add more detailed tags for cost tracking
- Set up different budgets for different environments (dev, test, prod)

## References

- [Azure Budget Tutorial](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- [Terraform Azure Budget Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription)
- Course materials from UAS Technikum Wien

---

**Student**: Hongqian Li(wi25x010)  
**Course**: Cloud Computing
**Institution**: UAS Technikum Wien (Exchange from HAMK)  
**Semester**: Winter 2025