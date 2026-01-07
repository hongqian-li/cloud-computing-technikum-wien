# Azure Web App with AI Sentiment Analysis

This project adds AI sentiment analysis to a web application using Azure Language Service. It also sets up secure networking with private endpoints and virtual networks.

## What This Assignment Does

This builds on Assignment 4 by adding:
1. Azure Language Service (AI for sentiment analysis)
2. Virtual Network with two subnets (one for web app, one for AI service)
3. Private endpoint for secure communication
4. Private DNS zone for name resolution
5. Web app integration with the virtual network

The result: A web app that can analyze if messages are positive, negative, or neutral, with secure private networking.

## Files in This Project

```
.
├── main.tf          # All infrastructure configuration
└── Variables.tf     # Variable definitions
```

## What Gets Created

When you run this Terraform code, it creates:

- **Resource Group**: Container for all resources
- **App Service Plan**: Hosting plan for the web app
- **Virtual Network**: Private network (10.0.0.0/16)
  - Web App Subnet (10.0.1.0/24)
  - AI Service Subnet (10.0.2.0/24)
- **Language Service**: Azure AI for text analysis
- **Private Endpoint**: Secure connection to AI service
- **Private DNS Zone**: For name resolution in the VNet
- **Linux Web App**: The Flask application
- **VNet Integration**: Connects web app to the virtual network

## Why Private Networking?

In this assignment, the AI service is NOT accessible from the public internet. Instead:
- The web app connects to AI service through the private network
- This is more secure than public endpoints
- Communication stays within Azure's network
- Uses private DNS for name resolution

## Prerequisites

- Azure account
- Terraform installed
- Azure CLI installed
- The Flask app repository (from Assignment 4)

## How to Deploy

### Step 1: Prepare Your Files

Make sure you have:
- `main.tf` with all the configuration
- `Variables.tf` with your settings
- Your web app repository set up with GitHub Actions (from Assignment 4)

### Step 2: Deploy Infrastructure

```bash
# Login to Azure
az login

# Initialize Terraform
terraform init

# Check what will be created
terraform plan

# Deploy everything
terraform apply
```

Type `yes` when prompted.

### Step 3: Verify in Azure Portal

Check that these resources were created:
1. Resource Group with all resources
2. Virtual Network with 2 subnets
3. Language Service (Cognitive Account)
4. Private Endpoint connected to AI subnet
5. Private DNS Zone linked to VNet
6. Web App with VNet integration

### Step 4: Check the AI Service Networking

1. Go to Azure Portal → Your Language Service
2. Click on "Networking" in the left menu
3. Verify:
   - Public access is DISABLED
   - Private endpoint is connected
   - Shows "Selected Networks and Private Endpoints"

### Step 5: Test Sentiment Analysis

1. Find your web app URL in Azure Portal
2. Open the web app in browser
3. Submit some messages (try positive and negative ones)
4. Click "Analyse sentiment" button
5. Should see sentiment results (positive/negative/neutral)

## How It Works

### The Networking Flow

```
User Browser
    ↓
Web App (in web subnet)
    ↓
Private Endpoint
    ↓
AI Language Service (in AI subnet)
    ↓
Returns sentiment analysis
```

### Environment Variables

The web app automatically gets these settings:
- `AZ_ENDPOINT`: URL of the AI service
- `AZ_KEY`: Access key for the AI service

Terraform sets these automatically through `app_settings` block.

## What I Learned

### Private Endpoints

Private endpoints let Azure services communicate securely without going through the public internet. Benefits:
- More secure (no public exposure)
- Traffic stays within Azure network
- Can control access more strictly

### Virtual Network Integration

The web app needs VNet integration to access the private endpoint. Without it, the web app couldn't reach the AI service because public access is disabled.

### Private DNS Zones

When using private endpoints, you need DNS to resolve the service name to the private IP address. That's why we created:
- Private DNS zone: `privatelink.cognitiveservices.azure.com`
- Link it to the VNet
- Configure it in the private endpoint

### Service Delegation

The web app subnet needs delegation to `Microsoft.Web/serverFarms` so Azure can manage the network integration properly.

## Common Problems I Encountered

**Issue: Sentiment analysis doesn't work**
- Check if Language Service was deployed correctly
- Verify the private endpoint is connected
- Make sure VNet integration is set up on the web app
- Check app settings have AZ_ENDPOINT and AZ_KEY

**Issue: Can't access AI service**
- This is expected! Public access is disabled
- The web app accesses it through private endpoint
- You can't test the AI service directly from your computer

**Issue: Terraform apply fails**
- Language Service names must be globally unique
- Try changing the cognitive_account_name variable
- Make sure you have enough quota in your subscription

**Issue: Private endpoint not connecting**
- Check subnet configuration
- Verify private_endpoint_network_policies is set correctly
- Make sure depends_on is set for the cognitive account

## Important Notes

### About the Language Service

- **SKU "S"** is a paid tier (not free)
- Can be expensive if left running
- **MUST delete after assignment** to avoid costs
- Deletion can take time - verify it's fully deleted

### Costs to Watch

This setup uses:
- App Service Plan (B1): ~$13/month
- Language Service (S tier): Pay per use
- VNet and Private Endpoint: Usually included

Make sure to run `terraform destroy` when done!

## Cleanup

**Very Important**: Delete everything to avoid charges

```bash
terraform destroy
```

Type `yes` when prompted.

Then verify in Azure Portal:
1. Check Resource Group is deleted
2. **Especially check Language Service is fully deleted**
3. Look for any leftover resources

## For Assignment Submission

Take screenshots of:
1. Azure Portal showing all created resources
2. Language Service networking page showing "Disabled" public access
3. Private endpoint connection status "Approved"
4. Web app with sentiment analysis working
5. Browser showing the web app URL
6. Sentiment analysis results displayed

## Assignment Context

This was Assignment 5 for Cloud Computing & Infrastructure course at UAS Technikum Wien (Winter 2025). The focus was on:
- Azure networking concepts (VNets, subnets, private endpoints)
- Integrating AI services into applications
- Secure communication patterns in cloud
- Private DNS configuration

## Key Concepts Covered

- **Virtual Networks**: Isolated network in Azure
- **Subnets**: Segments within a virtual network
- **Private Endpoints**: Secure access to Azure services
- **Private DNS Zones**: Name resolution for private endpoints
- **VNet Integration**: Connecting app services to virtual networks
- **Azure AI Services**: Language Service for sentiment analysis
- **Secure Architecture**: Disabling public access and using private connectivity

## Challenges I Faced

- Understanding the networking flow was confusing at first
- Figuring out why we need private DNS took time
- Learning about service delegation for the web subnet
- Making sure all the networking pieces connect properly
- Testing was harder because can't access AI service directly

## References

- [Azure Cognitive Account (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account)
- [Azure Subnet (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Azure Private Endpoint (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- [Azure Private DNS Zone Link (Terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link)
- Course materials from UAS Technikum Wien

---

**Student**: Hongqian (wi25x010)  
**Course**: Cloud Computing  
**Semester**: Winter 2025  
**Institution**: UAS Technikum Wien (Exchange from HAMK)