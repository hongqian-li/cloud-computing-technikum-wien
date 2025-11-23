# Pulumi Implementation - Assignment 2

## 📋 Overview

Provisions Azure infrastructure using Python:
- Azure Resource Group
- Azure Storage Account (ZRS)

## 🚀 Quick Start
```bash
# 1. Create virtual environment
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # macOS/Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Login to Pulumi (local)
pulumi login --local

# 4. Initialize stack
pulumi stack init dev

# 5. Configure
pulumi config set azure-native:location norwayeast
pulumi config set storageAccountName stassignment2pulumi
pulumi config set storageSku Standard_ZRS
pulumi config set resourceGroupName rg-assignment2-pulumi

# 6. Deploy
pulumi up

# 7. View outputs
pulumi stack output

# 8. Destroy
pulumi destroy
```

## 📁 Files

- `__main__.py` - Main Pulumi program
- `Pulumi.yaml` - Project configuration
- `requirements.txt` - Python dependencies
- `Pulumi.example.yaml` - Example stack config
- `.gitignore` - Git ignore rules

## 🔒 Security

- TLS 1.2 minimum
- HTTPS only
- No public blob access
- Secrets marked as sensitive