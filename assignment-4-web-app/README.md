# Azure Web App with CI/CD Pipeline

This project uses Terraform to create Azure infrastructure for hosting a Python Flask web app, then sets up automatic deployment using GitHub Actions.

## What This Project Does

1. Creates Azure infrastructure (Resource Group, App Service Plan, Web App) using Terraform
2. Connects the Azure Web App to a GitHub repository
3. Sets up CI/CD so any code change automatically deploys to Azure

**Note**: This repository only contains the Terraform files. The actual Flask application code is in a separate forked repository (https://github.com/hongqian-li/clco-demo).

## Files in This Project

```
.
├── main.tf              # Main Terraform configuration
└── Variables.tf         # Variable definitions
```

That's it! The Flask app code (app.py, templates, etc.) lives in the GitHub repository that gets deployed.

## What is CI/CD?

CI/CD means Continuous Integration/Continuous Deployment. In simple terms:
- You push code changes to GitHub
- GitHub Actions automatically builds and deploys your code
- Your website updates without you doing anything manually

It's like having a robot that automatically publishes your work whenever you save it.

## What You Need

- Azure account
- GitHub account  
- Terraform installed
- Azure CLI installed

## Step-by-Step Guide

### Step 1: Fork the Flask App Repository

1. Go to https://github.com/dmelichar/clco-demo
2. Click "Fork" (make sure it's public)
3. Clone it to your computer:
   ```bash
   git clone https://github.com/YOUR-USERNAME/clco-demo
   cd clco-demo
   ```

### Step 2: Deploy Azure Infrastructure

1. Put the Terraform files (main.tf and Variables.tf) in a separate folder

2. Login and deploy:
   ```bash
   az login
   terraform init
   terraform plan
   terraform apply
   ```

3. Check Azure Portal to see your resources were created

### Step 3: Connect GitHub to Azure (The Important Part!)

This is where the CI/CD magic happens:

1. Open Azure Portal → Find your Web App
2. Go to "Deployment Center" in the left menu
3. Click "Settings" tab
4. Choose these options:
   - Source: **GitHub**
   - Click "Authorize" and login to GitHub
   - Pick your forked repository
   - Select "main" branch
5. Click **Save**

**What happens now:**
- Azure creates a workflow file in your GitHub repo
- Your app deploys automatically
- Any time you push code changes, it redeploys automatically!

### Step 4: Check That It Worked

- Go to your Web App in Azure Portal
- Find the URL (looks like `app-clco-demo-group-3.azurewebsites.net`)
- Open it in browser - you should see your Flask app!

You can check deployment status in:
- Azure Portal → Deployment Center → Logs
- GitHub → Actions tab (to see the workflow running)

### Step 5: Test the Automatic Deployment

Try making a change to see CI/CD in action:

1. Edit something in `templates/index.html` in your clco-demo repo
2. Commit and push:
   ```bash
   git add .
   git commit -m "test change"
   git push
   ```
3. Go to GitHub → Actions - you'll see it running
4. Wait a few minutes, then refresh your website
5. Your change is live!

This is CI/CD - you push code, it automatically deploys.

## What I Learned From This Assignment

### Why PaaS is Useful

PaaS (Platform-as-a-Service) means Azure manages the servers for you. Benefits:
- Don't need to worry about server updates or security patches
- Can focus on writing code instead of managing infrastructure
- Easy to scale up if you get more traffic
- Comes with built-in features like HTTPS and monitoring

### The Downsides

But there are trade-offs:
- Less control - can't customize everything
- Costs can add up
- Harder to switch to a different cloud provider later
- Have to work within Azure's rules and limitations

### PaaS vs IaaS

**IaaS** (like Virtual Machines): You manage everything - OS, updates, security
**PaaS** (like App Service): Azure manages the platform, you just deploy code

PaaS is easier but less flexible. IaaS gives more control but more work.

### Why Use Terraform Instead of Azure Portal?

Using Terraform to create infrastructure has advantages:
- Can recreate the same setup easily
- Code is documentation
- Works well with teams (everyone uses same config)
- Can version control your infrastructure

But sometimes it's faster to just click around in Azure Portal for simple stuff.

## Cleaning Up

When done:
```bash
terraform destroy
```

Or just delete the resource group in Azure Portal.

## Common Problems

**Deployment failed in GitHub Actions**
- Check the Actions tab for error messages
- Make sure your repo is public
- Wait and try again - sometimes it just takes time

**Website shows "waiting for content"**
- Wait a few minutes - first deployment takes time
- Check Deployment Center logs

**Changes not showing up**
- Check if GitHub Actions ran
- Try hard refresh (Ctrl+F5)
- Sometimes takes 1-2 minutes

## Assignment Context

This was Assignment 4 for Cloud Computing & Infrastructure course at UAS Technikum Wien (Winter 2025). The main goals were:
- Learn how to use Terraform for Azure infrastructure
- Understand PaaS concepts
- Set up a CI/CD pipeline with GitHub Actions
- Compare different cloud service models

## References

- [Azure App Service docs](https://learn.microsoft.com/en-us/azure/app-service/overview)
- [Terraform azurerm_linux_web_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app)
- Course materials from UAS Technikum Wien

---

**Student**: Hongqian Li (wi25x010)  
**Course**: Cloud Computing  
**Semester**: Winter 2025  
**Institution**: UAS Technikum Wien (Exchange from HAMK)