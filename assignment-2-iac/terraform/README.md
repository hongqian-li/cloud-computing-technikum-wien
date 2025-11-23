# Terraform Implementation - Assignment 2

## 📋 Overview

This Terraform configuration creates:
- Azure Resource Group
- Azure Storage Account with ZRS replication

## 🚀 Usage

### Prerequisites
```bash
# Terraform installed
terraform --version  # >= 1.0

# Azure CLI logged in
az login
az account show
```

### Deployment Steps
```bash
# 1. Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your unique storage account name

# 2. Initialize
terraform init

# 3. Validate
terraform validate

# 4. Format
terraform fmt

# 5. Plan
terraform plan

# 6. Apply
terraform apply

# 7. View outputs
terraform output

# 8. Destroy (when done)
terraform destroy
```

## 📁 Files

- `main.tf` - Main resource definitions
- `variables.tf` - Input variable definitions
- `outputs.tf` - Output value definitions
- `terraform.tfvars.example` - Example variable values
- `.gitignore` - Git ignore rules

## ⚠️ Important Notes

1. **Storage Account Name**: Must be globally unique (3-24 chars, lowercase only)
2. **Location**: Must be austriaeast, norwayeast, or italynorth per assignment
3. **Never commit**: `terraform.tfvars` with real values to Git

## 🔒 Security

- `.tfvars` files are gitignored to prevent credential leaks
- Storage account has TLS 1.2 minimum
- Public access to nested items is disabled