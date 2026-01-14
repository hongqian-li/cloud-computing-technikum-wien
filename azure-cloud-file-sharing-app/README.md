# Cloud File Sharing Application

A secure, enterprise-grade file sharing application built on Azure infrastructure using Infrastructure as Code (Terraform) and Python Flask.

## Project Overview

This is my final project for the Cloud Computing course at UAS Technikum Wien. The application allows users to upload, store, and manage files securely in the cloud using Azure services with private networking.

### What This Application Does

- **Upload files** to Azure Blob Storage
- **Store metadata** in Azure SQL Database
- **Download and delete** files through a web interface
- **Secure access** through Application Gateway
- **Private networking** - all backend services communicate through private endpoints

## Architecture

```
Internet
    ↓
Application Gateway (Public IP)
    ↓
Azure Web App (Flask)
    ↓
    ├─→ Azure Blob Storage (via Private Endpoint)
    └─→ Azure SQL Database (via Private Endpoint)

All within Virtual Network
```
## Architecture
![cloud-computing-final-project-diagram](https://github.com/user-attachments/assets/64c6aa7d-b528-4edc-9bcc-cbef700cc91a)

### Key Features

- **Infrastructure as Code**: Everything deployed with Terraform
- **Private Networking**: Backend services not accessible from internet
- **Secure Storage**: Files stored in Azure Blob Storage
- **Database Integration**: File metadata in SQL Database
- **Monitoring**: Application Insights for performance tracking
- **Enterprise Security**: Private endpoints, NSG rules, HTTPS only

## Technologies Used

### Infrastructure (Terraform)
- Azure Virtual Network with 3 subnets
- Azure App Service (Linux, Python 3.11)
- Azure Storage Account
- Azure SQL Server and Database
- Application Gateway
- Private Endpoints and DNS Zones
- Network Security Groups

### Application (Python/Flask)
- Flask web framework
- Azure SDK for Python (blob storage)
- PyODBC for SQL database
- Gunicorn for production server

## Project Structure

```
clco-final-project/
├── terraform/
│   ├── main.tf           # Infrastructure configuration
│   ├── variables.tf      # Variable definitions
│   ├── outputs.tf        # Output values
│   └── provider.tf       # Terraform and provider config
├── webapp/
│   ├── app.py            # Main Flask application
│   ├── app_local.py      # Local development version
│   ├── requirements.txt  # Python dependencies
│   └── templates/
│       └── index.html    # Web UI
├── .gitignore
└── README.md
```

## Prerequisites

- Azure subscription
- Terraform >= 1.5.0
- Python 3.11
- Azure CLI
- Git

## Deployment Guide

### Step 1: Clone Repository

```bash
git clone <your-repo-url>
cd clco-final-project
```

### Step 2: Deploy Infrastructure with Terraform

```bash
cd terraform

# Login to Azure
az login

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy infrastructure
terraform apply
```

Type `yes` when prompted. This takes about 10-15 minutes.

### Step 3: Deploy Web Application

After infrastructure is deployed, you need to deploy the Flask app to Azure App Service.

#### Option A: Using Azure CLI

```bash
cd ../webapp

# Get your web app name from Terraform output
az webapp list --query "[].{name:name, resourceGroup:resourceGroup}" -o table

# Deploy using zip deployment
az webapp up --name <your-webapp-name> --resource-group <your-resource-group>
```

#### Option B: Using GitHub Actions (Recommended)

1. Push your code to GitHub
2. In Azure Portal, go to your Web App
3. Navigate to **Deployment Center**
4. Select **GitHub** as source
5. Connect your repository
6. Azure will automatically create a workflow file

### Step 4: Verify Deployment

1. Get the Application Gateway public IP:
   ```bash
   terraform output app_gateway_public_ip
   ```

2. Open in browser: `http://<public-ip>`

3. You should see the file upload interface!

## Local Development

You can run a simplified version locally for testing the UI.

### Setup Local Environment

```bash
cd webapp

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements_local.txt

# Run local development server
python app_local.py
```

Visit: `http://localhost:5000`

**Note**: Local version uses mock data. Full functionality requires Azure deployment.

## Configuration

### Environment Variables

The application uses these environment variables (set automatically by Terraform):

- `STORAGE_CONNECTION_STRING`: Azure Storage connection
- `STORAGE_CONTAINER_UPLOAD`: Container name for uploads
- `SQL_SERVER_FQDN`: SQL Server address
- `SQL_DATABASE`: Database name
- `SQL_USERNAME`: Database username
- `SQL_PASSWORD`: Database password
- `MAX_UPLOAD_BYTES`: Maximum file size (default: 10MB)
- `ALLOWED_FILE_TYPES`: Allowed extensions

### Customizing Settings

Edit `terraform/variables.tf` to change:

```hcl
# Maximum upload size (in bytes)
variable "max_upload_bytes" {
  default     = 10485760  # 10 MB
}

# Allowed file types
variable "allowed_file_types" {
  default     = [".jpg", ".jpeg", ".png", ".gif", ".pdf"]
}
```

Then re-deploy: `terraform apply`

## How It Works

### File Upload Flow

1. User selects file through web interface
2. Flask app validates file type and size
3. File uploaded to Azure Blob Storage
4. Metadata saved to SQL Database
5. User sees confirmation message

### Security Features

**Private Endpoints**: 
- Storage Account and SQL Database only accessible from VNet
- No public internet access to backend services

**Network Security Groups**:
- Restrict traffic to necessary ports only
- Allow HTTPS outbound for App Service
- Allow SQL port (1433) to database

**Application Gateway**:
- Single public entry point
- SSL/TLS termination
- Backend communicates over HTTPS

**HTTPS Only**:
- Web app forces HTTPS connections
- Minimum TLS 1.2

## Infrastructure Components Explained

### Phase 1: Networking
- **Virtual Network**: Private network (10.0.0.0/16)
- **3 Subnets**:
  - Application Gateway subnet (10.0.0.0/24)
  - App Service subnet (10.0.1.0/24) - with delegation
  - Private Endpoint subnet (10.0.2.0/24)

### Phase 2: Storage
- **Storage Account**: For file uploads
- **2 Containers**: 
  - `uploads`: User files
  - `tfstate`: Terraform state (for CI/CD)

### Phase 3: Database
- **SQL Server**: Managed database service
- **SQL Database**: Stores file metadata (name, size, upload time)
- **Private Endpoint**: Secure connection from VNet

### Phase 4: Web Application
- **App Service Plan**: Linux B1 tier
- **Web App**: Python 3.11 Flask application
- **VNet Integration**: Connects to private network
- **Application Insights**: Monitoring and logging

### Phase 5: Public Access
- **Application Gateway**: Layer 7 load balancer
- **Public IP**: Single point of entry
- **HTTP → HTTPS**: Backend communication

## What I Learned

### Azure Networking
- How virtual networks isolate cloud resources
- Private endpoints for secure service access
- DNS zones for name resolution in private networks
- Subnet delegation for App Service

### Infrastructure as Code
- Terraform for reproducible deployments
- Remote state management in Azure Storage
- Managing dependencies between resources
- Using locals and variables for DRY code

### Cloud Application Development
- Connecting Flask apps to Azure services
- Using Azure SDK for Python
- Database integration with SQL Server
- Environment variable configuration

### Security Best Practices
- Principle of least privilege (NSG rules)
- No direct public access to data services
- HTTPS everywhere
- Connection string management

## Challenges I Faced

### 1. Private Endpoint DNS Configuration
**Problem**: App couldn't connect to storage/database through private endpoints

**Solution**: Needed to:
- Create private DNS zones
- Link DNS zones to VNet
- Configure DNS zone groups in private endpoints

### 2. Storage Account Naming
**Problem**: Storage account names must be globally unique, lowercase, no special chars

**Solution**: Used string replacement and truncation:
```hcl
name = substr(replace(lower("${local.name_prefix}sa"), "-", ""), 0, 24)
```

### 3. App Service VNet Integration
**Problem**: App Service needs special subnet with delegation

**Solution**: Created dedicated subnet with:
```hcl
delegation {
  name = "app-service-delegation"
  service_delegation {
    name = "Microsoft.Web/serverFarms"
  }
}
```

### 4. SQL Database Connection
**Problem**: Connection string format and ODBC driver issues

**Solution**: Used specific connection string format:
```python
f"Driver={{ODBC Driver 17 for SQL Server}};Server=tcp:{SQL_SERVER},1433;..."
```

### 5. Application Gateway Configuration
**Problem**: Backend pool needed to connect to App Service over HTTPS

**Solution**: 
- Set backend port to 443
- Enable `pick_host_name_from_backend_address`
- Use App Service default hostname as FQDN

## Cost Considerations

Based on actual Azure pricing calculator estimate (Norway East region, December 2024):

| Service | Monthly Cost (EUR) |
|---------|-------------------|
| Application Gateway (Standard V2) | €186.12 |
| Virtual Network (data transfer) | €15.57 |
| App Service (B1) | €11.17 |
| Storage Account (1TB capacity) | €19.75 |
| Azure SQL Database (Basic) | €4.66 |
| **Total** | **€237.28/month** |

**Important Notes:**
- Application Gateway is the most expensive component (78% of total cost!)
- Prices shown are in Euros (EUR) for Norway East region
- Actual costs may vary based on actual usage and data transfer

**Cost Optimization Tips:**
- For learning/testing: Remove Application Gateway and access Web App directly
- Delete all resources when not in use (don't forget!)
- Consider using cheaper Azure regions
- Use Basic/Free tiers where possible

## Cleanup

**Very Important**: Delete all resources to avoid charges!

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted.

Verify in Azure Portal that everything is deleted.

## Troubleshooting

### Issue: App shows "Connection Failed" error
**Solution**: 
- Check if private endpoints are connected
- Verify DNS zones are linked to VNet
- Check NSG rules allow necessary traffic

### Issue: Can't access through Application Gateway
**Solution**:
- Wait 5-10 minutes after deployment (AG takes time to configure)
- Check backend health in Azure Portal
- Verify Web App is running

### Issue: Database connection errors
**Solution**:
- Verify SQL credentials in app settings
- Check if private endpoint is approved
- Ensure VNet integration is active on Web App

### Issue: Files not uploading
**Solution**:
- Check storage connection string in app settings
- Verify container exists
- Check NSG rules allow outbound HTTPS

### Issue: Terraform apply fails
**Solution**:
- Check Azure subscription quotas
- Verify unique naming (storage account, web app)
- Try different Azure region

## Testing the Application

### 1. Upload Test
1. Access application through Application Gateway IP
2. Select a file (.jpg, .png, .gif, or .pdf)
3. Click "Upload File"
4. File should appear in the list below

### 2. Download Test
1. Click "Download" on any uploaded file
2. File should download to your computer
3. Verify file content is correct

### 3. Delete Test
1. Click "Delete" on any file
2. Confirm deletion
3. File should disappear from list

### 4. Database Test
Visit: `http://<app-gateway-ip>/debug/sql`

Should show JSON with all file metadata from database.

### 5. Health Check
Visit: `http://<app-gateway-ip>/health`

Should return: `{"status": "healthy"}`

## Future Improvements

If I continue this project, I could add:

- **User Authentication**: Azure AD B2C login
- **File Sharing**: Generate share links for files
- **Virus Scanning**: Integrate with Azure Defender
- **CDN**: Azure CDN for faster downloads
- **Backup**: Automated database and storage backups
- **Monitoring Alerts**: Email notifications for errors
- **Multi-region**: Deploy in multiple regions for HA
- **Docker**: Containerize the application

## Project Context

This project was completed for the **Cloud Computing & Infrastructure** course at **UAS Technikum Wien (Winter Semester 2025)**. 

The project demonstrates:
- Infrastructure as Code principles
- Azure PaaS services integration
- Secure cloud architecture design
- Full-stack cloud application development
- DevOps practices

## References

### Azure Documentation
- [Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [App Service](https://learn.microsoft.com/en-us/azure/app-service/overview)
- [Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview)
- [Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-introduction)
- [Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview)

### Terraform Documentation
- [AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app)
- [Private Endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- [Application Gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway)

### Course Materials
- UAS Technikum Wien Cloud Computing course materials
- Assignments 4-8 (building blocks for this project)

## License

This project was created for educational purposes as part of university coursework.

---

**Student**: Hongqian (wi25x010)  
**Course**: Cloud Computing & Infrastructure  
**Semester**: Winter 2025  
**Institution**: UAS Technikum Wien (Exchange from HAMK University of Applied Sciences)  
**Date**: January 2026

---

*This project demonstrates practical skills in cloud architecture, infrastructure automation, secure networking, and full-stack development - key competencies for Cloud Engineer and DevOps roles.*
