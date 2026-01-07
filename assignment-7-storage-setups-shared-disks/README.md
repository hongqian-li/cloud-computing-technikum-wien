# Azure Managed Disks and Backup Configuration

This project adds managed disks to virtual machines and sets up automatic backups using Azure Recovery Services Vault.

## What This Assignment Does

This builds on Assignment 6 (Load Balancer) by adding:
1. Two managed disks (1TB each, Premium SSD)
2. Disks attached to the two VMs
3. Recovery Services Vault for backups
4. Backup policy (daily at 22:00, 30-day retention)
5. Backup protection configured for both VMs

## Project Structure

```
.
├── main.tf           # Core infrastructure from Assignment 6
├── disks.tf          # Managed disks and backup configuration
├── variables.tf      # Variable definitions
└── scripts/
    └── install-nginx.sh  # Auto-install Nginx on VMs
```

## What Gets Created

### From Previous Assignment (Assignment 6):
- Resource Group
- Virtual Network + Subnet
- 2 Linux Virtual Machines (Standard_F2s_v2)
- 2 Network Interfaces
- Load Balancer with Public IP
- Network Security Group
- Health Probe and Load Balancing Rules

### New for Assignment 7:
- **2 Managed Disks** (1024 GB Premium SSD LRS each)
- **Disk Attachments** to VMs
- **Recovery Services Vault**
- **Backup Policy** (daily at 22:00, 30-day retention)
- **Backup Protection** for both VMs

## What are Managed Disks?

Managed disks are like virtual hard drives that you can:
- Attach to VMs to store data
- Detach from one VM and attach to another
- Back up and restore
- Scale in size

Think of them as USB drives, but virtualized in the cloud.

## Prerequisites

- Azure account
- Terraform installed
- Azure CLI installed
- SSH key pair generated
- Code from Assignment 6 (Load Balancer setup)

## How to Deploy

### Step 1: Prepare Your SSH Key

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key

# Note the path to your public key
# Usually: ~/.ssh/azure_key.pub
```

### Step 2: Update Variables

Edit `variables.tf` if needed, or create `terraform.tfvars`:

```hcl
ssh_public_key_path = "~/.ssh/azure_key.pub"
admin_username      = "azureuser"
```

### Step 3: Deploy Everything

```bash
# Login to Azure
az login

# Initialize Terraform
terraform init

# Check what will be created
terraform plan

# Deploy all resources
terraform apply
```

Type `yes` when prompted.

This will take about 5-10 minutes to create all resources.

### Step 4: Verify in Azure Portal

1. **Check VMs and Disks**:
   - Go to Resource Group
   - Find your 2 VMs
   - Click on each VM → "Disks" section
   - You should see the OS disk + 1 data disk attached

2. **Check Recovery Services Vault**:
   - Find the Recovery Vault in your resource group
   - Go to "Backup items" → "Azure Virtual Machine"
   - Should show 2 VMs protected

3. **Check Backup Policy**:
   - In Recovery Vault, go to "Backup policies"
   - Click on your policy
   - Verify: Daily at 22:00, 30-day retention

## Testing Backup Manually

### Step 1: Trigger Manual Backup

You can't do this with Terraform - must use Azure Portal:

1. Go to Recovery Services Vault
2. Click "Backup items" → "Azure Virtual Machine"
3. Click on one of your VMs
4. Click "Backup now"
5. Set retention date (e.g., 3-7 days from now)
6. Click "OK"

### Step 2: Monitor Backup Job

1. In Recovery Vault, go to "Backup jobs"
2. Find your backup job
3. Watch status change from "In Progress" to "Completed"
4. Usually takes 10-30 minutes

### Step 3: Verify Backup

1. Go to VM backup details
2. Click "Restore Points"
3. Should see the backup you just created with retention date

## What I Learned

### Managed Disks vs OS Disks

- **OS Disk**: Where the operating system lives, created automatically with VM
- **Data Disk**: Extra storage you add, can be moved between VMs
- Both are "managed" (Azure handles the complexity)

### Disk Types

There are different performance tiers:
- **Standard HDD**: Cheapest, slower
- **Standard SSD**: Medium cost, medium speed
- **Premium SSD**: Fastest, most expensive (what we used)
- **Ultra Disk**: Extremely fast, very expensive

We used Premium SSD LRS because:
- Good performance
- LRS = Locally Redundant Storage (3 copies in same datacenter)
- Required for F-series VMs

### Backup Concepts

**Recovery Services Vault**: Container that stores all your backups

**Backup Policy**: Rules for when and how often to backup
- Our policy: Daily at 22:00, keep for 30 days
- This means: backup every night, delete backups older than 30 days

**Backup Protected VM**: Links a VM to a backup policy

### Why LUN = "0"?

LUN (Logical Unit Number) is like the disk's ID on the VM. 
- First data disk: LUN 0
- Second data disk (if you had one): LUN 1
- And so on...

## Common Issues I Encountered

**Issue: Backup policy requires specific time format**
- Must use 24-hour format: "22:00" not "10:00 PM"
- Time is in UTC

**Issue: Can't delete Recovery Vault**
- Must first delete all backup items
- Then disable soft delete
- Then can delete the vault
- This can take time!

**Issue: Premium SSD requires certain VM sizes**
- Not all VM sizes support Premium SSD
- Standard_F2s_v2 supports it (that's why we use it)

**Issue: Terraform can't trigger manual backups**
- Automatic backups work through policy
- Manual backups must be done in Portal
- This is a limitation of Terraform

## Using the Disks on VMs

After deployment, the disks are attached but not formatted. To use them on the VMs:

```bash
# SSH into VM
ssh azureuser@<vm-public-ip>

# List disks
lsblk

# You'll see something like sdc or sdd (your data disk)
# Format it (WARNING: destroys data!)
sudo mkfs.ext4 /dev/sdc

# Create mount point
sudo mkdir /datadisk

# Mount it
sudo mount /dev/sdc /datadisk

# Make it permanent (add to /etc/fstab)
```

But be careful - if you restore from backup, the disk will be restored to its backed-up state.

## Cost Considerations

This setup costs money:
- **2 VMs (F2s_v2)**: ~$70-100/month each
- **2 Premium SSD (1TB)**: ~$122/month each
- **Load Balancer**: ~$18/month
- **Recovery Vault storage**: Based on backup size
- **Total**: ~$400-450/month

**Important**: Delete resources after testing!

## Cleanup

**Method 1: Terraform Destroy**

```bash
terraform destroy
```

**Method 2: Manual Portal Deletion**

Some resources need manual deletion in this order:

1. **Stop backup protection**:
   - Recovery Vault → Backup items
   - For each VM: "Stop backup" → "Delete backup data"

2. **Delete Recovery Vault**:
   - Go to vault settings
   - Disable "Soft Delete"
   - Delete the vault

3. **Delete Resource Group**:
   - This deletes everything else

**Note**: Recovery Vault can be tricky to delete. If `terraform destroy` fails, use manual method above.

## For Assignment Submission

Take screenshots of:

1. **Resource Group Overview**:
   - Showing all resources created

2. **VM Disks**:
   - For each VM, show "Disks" page with data disk attached

3. **Managed Disks**:
   - List of managed disks showing size (1024 GB) and type (Premium SSD LRS)

4. **Recovery Services Vault**:
   - Backup items showing 2 protected VMs

5. **Backup Policy**:
   - Policy details showing daily at 22:00, 30-day retention

6. **Backup Job**:
   - Manual backup job you triggered
   - Status showing "Completed"

7. **Restore Points**:
   - Restore points for one VM showing the backup with retention date

## Assignment Context

This was Assignment 7 for Cloud Computing & Infrastructure course at UAS Technikum Wien (Winter 2025). The focus was on:
- Azure Storage concepts (Managed Disks)
- Understanding disk types and performance tiers
- Backup and disaster recovery planning
- Working with Azure Recovery Services
- Managing VM data persistence

## Key Concepts Covered

- **Managed Disks**: Virtual hard drives in Azure
- **Disk Attachment**: Connecting disks to VMs
- **Recovery Services Vault**: Backup infrastructure
- **Backup Policies**: Automated backup schedules
- **Backup Protection**: Linking VMs to backup policies
- **Restore Points**: Snapshots for recovery
- **Storage Redundancy**: LRS (Locally Redundant Storage)
- **Disk Performance Tiers**: Premium SSD vs Standard

## Challenges I Faced

- Understanding the difference between OS disks and data disks
- Figuring out LUN numbering for disk attachments
- Learning that Terraform can't trigger manual backups
- Dealing with Recovery Vault deletion (needs special steps)
- Configuring the correct time format for backup policy
- Making sure VM size supports Premium SSD

## Why This Matters

In real cloud environments:
- **Data persistence**: VMs can be deleted but disks preserved
- **Disaster recovery**: Regular backups prevent data loss
- **Migration**: Disks can be moved between VMs
- **Scalability**: Storage can grow independently of compute
- **Compliance**: Many industries require backup retention policies

## References

- [Azure Managed Disks (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)
- [Virtual Machine Data Disk Attachment (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment)
- [Recovery Services Vault (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault)
- [Backup Protected VM (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm)
- Course materials from UAS Technikum Wien

---

**Student**: Hongqian (wi25x010)  
**Team**: Group 3 (Bienias Kamil, Paradzik Marko, Zelimchanow Chamberg, Ramazanov Muslim)  
**Course**: Cloud Computing  
**Semester**: Winter 2025  
**Institution**: UAS Technikum Wien (Exchange from HAMK)