# Azure VM Monitoring and Boot Diagnostics

This project adds monitoring capabilities and boot diagnostics to virtual machines, building on previous assignments.

## What This Assignment Does

This builds on Assignments 6 & 7 by adding:
1. Storage Account for boot diagnostics
2. Boot diagnostics enabled on the first VM
3. Viewing metrics (CPU usage, network traffic)
4. Setting up alerts for monitoring
5. Verifying boot diagnostics screenshots

## Project Structure

```
.
├── main.tf           # Complete infrastructure including monitoring
├── variables.tf      # Variable definitions
└── scripts/
    └── install-nginx.sh  # Auto-install Nginx on VMs
```

## What Gets Created

### Complete Infrastructure:
- Resource Group
- Virtual Network + Subnet
- 2 Linux Virtual Machines (Standard_F2s_v2)
- **Storage Account** (for boot diagnostics) - NEW for Assignment 8
- Load Balancer with Public IP
- 2 Managed Disks (1TB Premium SSD each)
- Network Security Group
- Recovery Services Vault with Backup Policy

### New for Assignment 8:
- **Boot Diagnostics enabled** on VM-1
- **Metrics monitoring** configured in Portal
- **Alerts** for threshold monitoring

## What is Monitoring?

Azure automatically collects metrics for VMs:
- **CPU usage**: How much processing power is being used
- **Network traffic**: Data coming in and out
- **Disk usage**: Storage read/write operations
- **Boot diagnostics**: Screenshots and logs when VM starts

These metrics help you:
- Know if your VM is healthy
- Detect problems early
- Plan for scaling

## What are Boot Diagnostics?

Boot diagnostics capture:
- **Screenshot**: What the VM screen shows during boot
- **Serial log**: Text output from the boot process

This helps when a VM won't start - you can see what went wrong.

## Prerequisites

- Azure account
- Terraform installed
- Azure CLI installed
- SSH key pair
- Code from Assignments 6 & 7

## How to Deploy

### Step 1: Prepare SSH Key

```bash
# Use existing key or generate new one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key
```

### Step 2: Update Variables (if needed)

```bash
# Edit variables.tf or create terraform.tfvars
ssh_public_key_path = "~/.ssh/azure_key.pub"
```

### Step 3: Deploy Infrastructure

```bash
# Login to Azure
az login

# Initialize Terraform
terraform init

# Deploy everything
terraform plan
terraform apply
```

Type `yes` when prompted. Takes about 10-15 minutes.

## Viewing Metrics in Azure Portal

After deployment, go to Azure Portal to view metrics.

### Step 1: Navigate to VM

1. Azure Portal → Virtual Machines
2. Click on your first VM (`sd-a8-vm-1`)
3. In left menu, find **Monitoring** section → **Metrics**

### Step 2: Add CPU Metric

1. Click "Add metric"
2. Configure:
   - **Metric Namespace**: Virtual Machine Host
   - **Metric**: Percentage CPU
   - **Aggregation**: Max

### Step 3: Add Network Metric

1. Click "Add metric" again
2. Configure:
   - **Metric Namespace**: Virtual Machine Host
   - **Metric**: Inbound Flows
   - **Aggregation**: Avg

### Step 4: Adjust Time Range

1. Top right corner: Click time range dropdown
2. Change to "Last 30 minutes"
3. Click Apply

Now you see a graph with both metrics!

## Viewing Boot Diagnostics

### Step 1: Access Boot Diagnostics

1. In your VM page, left menu → **Help** section
2. Click **Boot diagnostics**
3. You'll see two tabs:
   - **Screenshot**: Visual of boot screen
   - **Serial log**: Text output from boot

### Step 2: Verify Configuration

1. Click **Settings** in top menu
2. Verify:
   - Status: **Enabled with custom storage account**
   - Storage account: Your boot diagnostics storage account

### Step 3: Refresh and View

1. Click **Refresh** in top menu
2. View the screenshot - should show Linux boot screen
3. Check serial log for boot messages

## Setting Up Alerts

Alerts notify you when something goes wrong. You can set them up manually in Portal or with Terraform.

### Manual Alert Setup (Recommended for Learning)

1. Go to your VM → **Monitoring** → **Alerts**
2. Click **Create** → **Alert rule**
3. Configure:
   - **Scope**: Your VM (already selected)
   - **Condition**: Click "Add condition"
     - Signal: "Percentage CPU"
     - Threshold: Greater than 80%
     - Check frequency: Every 5 minutes
   - **Actions**: 
     - Can add email notification (optional)
     - Or just create alert without action
   - **Details**:
     - Name: "High CPU Alert"
     - Severity: Warning
4. Click **Review + create**

### Example Alert Scenarios

Good alerts to set up:
- CPU > 80% for 5 minutes
- Available memory < 20%
- Disk IOPS > threshold
- Network traffic unusual patterns

## What I Learned

### Why Monitoring Matters

In real cloud environments, you need to:
- **Detect problems**: Know when something breaks
- **Prevent downtime**: Fix issues before users notice
- **Optimize costs**: See if you're using too much or too little resources
- **Plan capacity**: Know when to scale up

### Metrics vs Logs vs Diagnostics

- **Metrics**: Numbers (CPU %, network bytes)
- **Logs**: Text messages from applications
- **Boot Diagnostics**: Special logs for VM startup

### Azure Monitor Components

- **Metrics**: Automatic numeric data collection
- **Alerts**: Notifications when thresholds are exceeded
- **Boot Diagnostics**: Startup troubleshooting
- **Log Analytics**: Advanced log querying (not in this assignment)

### Storage Account for Diagnostics

Boot diagnostics need a place to store screenshots and logs. That's why we created a storage account. It's cheap and necessary for debugging VM boot problems.

## Common Issues I Encountered

**Issue: Boot diagnostics not showing**
- Wait 5-10 minutes after deployment
- Click Refresh in the portal
- Make sure storage account is created
- VM must have been restarted at least once

**Issue: Metrics showing no data**
- Metrics take time to populate (5-15 minutes)
- VM must be running
- Try changing time range to "Last hour"

**Issue: Can't see screenshot clearly**
- Screenshot quality depends on VM boot state
- Try restarting VM to get new screenshot
- Some VMs boot so fast, screenshot is just boot screen

**Issue: Storage account name too long**
- Storage account names max 24 characters
- Must be lowercase, no special characters
- We use random suffix to make it unique

## Understanding the Code

### Boot Diagnostics Configuration

```hcl
boot_diagnostics {
  storage_account_uri = count.index == 0 ? 
    azurerm_storage_account.boot_diagnostics.primary_blob_endpoint : null
}
```

This means:
- `count.index == 0`: Only enable for first VM (VM-1)
- `? ... : null`: If condition true, use storage account; else disable
- Other VM (VM-2) doesn't have boot diagnostics enabled

### Random Storage Name

```hcl
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}
```

Why? Storage account names must be:
- Globally unique across all Azure
- 3-24 characters
- Only lowercase and numbers

Random suffix ensures uniqueness.

## Cost Considerations

This setup costs:
- 2 VMs (F2s_v2): ~$70-100/month each
- 2 Premium SSDs (1TB): ~$122/month each
- Load Balancer: ~$18/month
- Storage for boot diagnostics: ~$1-2/month
- Recovery Vault: Based on backup size
- **Total: ~$400-450/month**

**Important**: Delete after testing!

## Cleanup

```bash
terraform destroy
```

If Recovery Vault fails to delete:
1. Manually stop backup protection
2. Delete backup data
3. Disable soft delete
4. Then delete resource group

## For Assignment Submission

Take screenshots of:

1. **Resource Group Overview**:
   - All resources including storage account

2. **Storage Account**:
   - Show the boot diagnostics storage account

3. **VM Boot Diagnostics Configuration**:
   - Settings page showing "Enabled with custom storage account"

4. **Boot Diagnostics Screenshot Tab**:
   - The actual boot screenshot from VM-1

5. **Boot Diagnostics Serial Log**:
   - Serial console output

6. **Metrics Page**:
   - Graph showing Percentage CPU and Inbound Flows
   - Time range set to Last 30 minutes
   - Both metrics visible on same graph

7. **Alerts Page**:
   - Alert rules configured
   - Show alert rule details

8. **VM Tags** (optional):
   - Show VM-1 has boot_diagnostics = "enabled" tag

## Assignment Context

This was Assignment 8 for Cloud Computing & Infrastructure course at UAS Technikum Wien (Winter 2025). The focus was on:
- Azure monitoring capabilities
- Understanding VM metrics
- Boot diagnostics for troubleshooting
- Alert configuration
- Storage account usage for diagnostics

## Key Concepts Covered

- **Azure Monitor**: Platform for collecting metrics and logs
- **Metrics**: Numeric performance data
- **Boot Diagnostics**: VM startup troubleshooting
- **Storage Account**: Blob storage for diagnostic data
- **Alerts**: Automated notifications based on conditions
- **Aggregation**: How metrics are calculated (Max, Avg, Min, Sum)
- **Time Series Data**: Metrics plotted over time

## Challenges I Faced

- Understanding why boot diagnostics need a storage account
- Figuring out the storage account naming requirements (24 chars, lowercase only)
- Learning that metrics take time to appear (not instant)
- Realizing only VM-1 needs boot diagnostics, not both
- Understanding conditional expressions in Terraform (`count.index == 0 ? ... : null`)
- Setting up alerts for the first time

## Why This Matters

In production environments:
- **Troubleshooting**: Boot diagnostics help when VMs won't start
- **Performance monitoring**: Metrics show if you need to scale
- **Cost optimization**: See if you're over-provisioned
- **Proactive management**: Alerts notify you before users complain
- **Compliance**: Many industries require monitoring and logging

## Real-World Monitoring Tips

What I learned about good monitoring:
1. **Don't alert on everything**: Too many alerts = ignored alerts
2. **Set realistic thresholds**: 80% CPU is usually fine, 95% is not
3. **Monitor trends**: One spike is okay, sustained high usage is not
4. **Use multiple metrics**: CPU + memory + disk together tell full story
5. **Test alerts**: Make sure they actually work

## References

- [Azure Monitor Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/overview)
- [Azure Monitor Alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
- [Create Metric Alert Rule](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-create-metric-alert-rule)
- [Boot Diagnostics for Azure VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics)
- [Azure Storage Account (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- Course materials from UAS Technikum Wien

---

**Student**: Hongqian (wi25x010)  
**Team**: Group 3 (Bienias Kamil, Paradzik Marko, Zelimchanow Chamberg, Ramazanov Muslim)  
**Course**: Cloud Computing  
**Semester**: Winter 2025  
**Institution**: UAS Technikum Wien (Exchange from HAMK)