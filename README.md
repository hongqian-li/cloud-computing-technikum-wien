# Cloud Computing Course - UAS Technikum Wien

My assignments and final project from Cloud Computing course (Winter 2025).

## About

This is my coursework from a semester exchange at UAS Technikum Wien in Vienna. I'm a final-year Computer Applications student from HAMK (Finland), graduating in June 2026. The course covered Azure cloud services, Terraform, and cloud architecture.

## What's in This Repo

```
├── assignment-2-iac/          # First Terraform deployment
├── assignment-3-budget/       # Azure budget management
├── assignment-4-cicd/         # CI/CD with GitHub Actions
├── assignment-5-ai-private/   # AI services + private networking
├── assignment-6-loadbalancer/ # Load balancer setup
├── assignment-7-backup/       # Managed disks and backup
├── assignment-8-monitoring/   # VM monitoring
└── azure-cloud-file-sharing-app/             # File sharing app
```

## Assignments

### Assignment 2: Infrastructure as Code
First time using Terraform and pulumi. Created basic Azure resources (VNet, VM, storage) to understand IaC concepts.

**What I learned**: Writing Terraform and pulumi configs, understanding resource dependencies, dealing with Azure provider.

### Assignment 3: Budget Management
Set up Azure budgets using Terraform to track spending and get email alerts.

**What I learned**: Why cost management matters, actual vs forecasted spending alerts.

### Assignment 4: CI/CD Pipeline
Deployed a Flask app to Azure App Service with automatic deployment using GitHub Actions.

**What I learned**: How CI/CD works, GitHub Actions workflows, App Service deployment.

### Assignment 5: AI with Private Networking
Added Azure Language Service (sentiment analysis) to a web app, using private endpoints so the AI service isn't accessible from the internet.

**What I learned**: Private endpoints, private DNS zones, VNet integration. This was confusing at first but makes sense for security.

### Assignment 6: Load Balancer
Set up a load balancer to distribute traffic across 2 VMs running Nginx.

**What I learned**: Backend pools, health probes, how load balancers actually work.

### Assignment 7: Backup and Storage
Added managed disks to VMs and configured automated backups.

**What I learned**: Different disk types, backup policies, Recovery Services Vault, why Premium SSD costs more.

### Assignment 8: Monitoring
Enabled boot diagnostics and set up metrics monitoring for VMs.

**What I learned**: Azure Monitor, boot diagnostics for troubleshooting, setting up alerts.

## Final Project: File Sharing App

Built a file-sharing web application using Azure services. Users can upload, download, and delete files through a web interface.

**Architecture**:
- Flask web app on Azure App Service
- Files stored in Azure Blob Storage
- File metadata in Azure SQL Database
- Application Gateway for public access
- Everything connected through private endpoints (no public access to backend services)

**Tech**: Terraform, Python/Flask, Azure (App Service, Storage, SQL Database, Application Gateway, Private Endpoints)

**Cost**: €237/month (mostly Application Gateway at €186/month)

The trickiest part was getting private endpoints and DNS zones working correctly. DNS is always the problem.

[See detailed docs →](https://github.com/hongqian-li/cloud-computing-technikum-wien/tree/main/clco-final-project)

## Main Things I Learned

**Infrastructure as Code**: Terraform lets you define infrastructure in code instead of clicking through Azure Portal. Makes it reproducible and you can version control it.

**Private Networking**: How to properly secure cloud services using VNets and private endpoints. Public access isn't always the answer.

**Cost Awareness**: Cloud services cost real money. Application Gateway alone was €186/month, which is 78% of my project budget.

**Troubleshooting**: Things rarely work on the first try. Most issues were related to DNS, permissions, or networking. Learning to read error messages and Azure docs was important.

## Common Problems I Hit

**Private endpoint DNS**: Services couldn't talk to each other through private endpoints. Solution: create private DNS zones and link them to the VNet.

**Storage account naming**: Names must be globally unique, lowercase only, no special characters, max 24 chars. Had to use Terraform string functions to generate valid names.

**Terraform state conflicts**: When working with teammates, we kept overwriting each other's changes. Solution: remote state backend in Azure Storage.

**VNet integration**: App Service couldn't connect to VNet. Solution: subnet needs delegation to `Microsoft.Web/serverFarms`.

**Application Gateway cost**: Way more expensive than I expected. For learning purposes, you can skip it and access the web app directly.

## Tech Stack

- **Cloud**: Azure
- **IaC**: Terraform, Pulumi
- **Programming**: Python, Bash
- **CI/CD**: GitHub Actions
- **Web**: Flask

## Skills Gained

Working with Azure services: App Service, Storage, SQL Database, Virtual Networks, Application Gateway, Load Balancer, Recovery Services, AI Services

Infrastructure as Code with Terraform

Private networking and security (private endpoints, NSGs, VNet integration)

CI/CD pipelines

Cost management and optimization

Troubleshooting cloud deployments

## What I'd Do Differently

- Use Terraform modules to organize code better
- Set up dev/staging/prod environments properly
- Add more testing before deploying
- Document as I go instead of at the end
- Keep better track of costs earlier

## Notes

This was my first real cloud infrastructure course. Before this, I had only used basic cloud services. The learning curve was steep, especially understanding networking and security concepts, but I learned a lot about how cloud systems actually work in production.

Some assignments were done in groups, but I wrote all my own Terraform code and documentation.

---

**Student**: Hongqian Li (wi25x010)  
**Home University**: HAMK University of Applied Sciences, Finland  
**Exchange**: UAS Technikum Wien, Austria  
**Semester**: Winter 2025  
**Graduating**: June 2026
