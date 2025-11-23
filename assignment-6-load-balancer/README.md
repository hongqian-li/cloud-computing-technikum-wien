# Assignment 6: Azure Load Balancer Setup

Simple guide to deploy a load-balanced web application on Azure using Terraform.

---

## What This Does

Creates 2 web servers behind a load balancer in Azure. When you visit the public IP, you'll see responses from different servers.

---

## What You Need

- **Azure account** with credits
- **Terraform** installed ([download here](https://www.terraform.io/downloads))
- **Azure CLI** installed ([download here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))

---

## Quick Start

### 1. Get the Code
```bash
git clone https://github.com/hongqian-li/cloud-computing-technikum-wien.git
cd cloud-computing-technikum-wien/assignment-6-load-balancer
```

### 2. Login to Azure
```bash
az login
```

### 3. Create SSH Key

**Windows:**
```powershell
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
```

**Mac/Linux:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### 4. Configure Your Settings

Copy the example file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and add your SSH key path:

**Windows example:**
```hcl
ssh_public_key_path = "C:/Users/YourName/.ssh/id_rsa.pub"
```

**Mac/Linux example:**
```hcl
ssh_public_key_path = "/home/username/.ssh/id_rsa.pub"
```

### 5. Deploy
```bash
# Initialize
terraform init

# Check what will be created
terraform plan

# Create everything
terraform apply
# Type: yes
```

⏰ **Wait 5-10 minutes** for deployment to complete.

### 6. Test

Get your public IP:
```bash
terraform output public_ip_address
```

Open in browser:
```
http://YOUR_PUBLIC_IP
```

Refresh the page multiple times - you'll see different server names!

### 7. Clean Up (Important!)

When done testing:
```bash
terraform destroy
# Type: yes
```

This deletes everything and stops charges.

---

## Project Files
```
assignment-6-load-balancer/
├── main.tf                    # All Azure resources
├── variables.tf               # Settings you can change
├── outputs.tf                 # Shows IP address after deployment
├── terraform.tfvars          # Your personal settings (don't commit!)
├── terraform.tfvars.example  # Template for settings
└── scripts/
    └── install-nginx.sh      # Installs web server automatically
```

---

## What Gets Created

- 2 Virtual Machines (Ubuntu with Nginx)
- 1 Load Balancer
- 1 Public IP address
- 1 Virtual Network
- Network security rules

**Total: 18 Azure resources**

---

## Troubleshooting

### "Website not loading"
Wait 5 minutes after deployment. The web servers need time to install.

### "SSH key not found"
Make sure you created the SSH key (step 3) and put the correct path in `terraform.tfvars`.

### "Permission denied"
Run `az login` again.

---

## Cost

- **Standard_B1s VMs:** ~€10/month each
- **Load Balancer:** ~€20/month
- **Total:** ~€34/month

**Testing for 1 hour:** ~€0.05

**Always run `terraform destroy` when done!**

---

## How It Works
```
Internet → Public IP → Load Balancer → VM1 or VM2 → Nginx Web Server
```

The Load Balancer automatically:
- Checks if VMs are healthy (every 15 seconds)
- Distributes traffic between healthy VMs
- Removes unhealthy VMs from rotation

---

## Authors

Hongqian Li, Bienias Kamil, Paradzik Marko, Zelimchanow Chamberg, Ramazanov Muslim

UAS Technikum Wien - Cloud Computing 

---

## Need Help?

1. Check the error message
2. Google the error
3. Ask your teammates
4. Contact instructor

---

That's it! 🎉