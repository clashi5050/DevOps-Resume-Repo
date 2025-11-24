Phase 1: Preparation & GitHub Setup
Goal: Establish your codebase and secure your infrastructure state before writing infrastructure code.

Step 1: Create the Repository Structure
Create Remote Repo:

Navigate to GitHub.com/new.

Name: devops-resume-repo (or similar professional name).

Visibility: Public.

Click: Create repository.

Clone & Scaffold Locally: Open your terminal and execute the following commands to set up the directory skeleton:

Bash

# Clone the repository
git clone https://github.com/your-username/devops-resume-repo.git
cd devops-resume-repo

# Create directory structure
mkdir -p src terraform/modules/static-app .github/workflows

# Verify structure
# You now have folders for source code, infrastructure, and CI/CD logic.
Step 2: Set up Azure Remote State
We need a secure, remote location to store the terraform.tfstate file so your team (or future you) creates resources consistently.

In the Azure Portal (portal.azure.com):

Create Resource Group:

Search for Resource groups > Click + Create.

Name: rg-tfstate-devops

Region: (Select your preferred region, e.g., East US).

Click Review + create > Create.

Create Storage Account:

Search for Storage accounts > Click + Create.

Resource Group: rg-tfstate-devops

Name: tfstatestoredevops8642 (Must be unique, lowercase, no spaces).

Redundancy: Locally-redundant storage (LRS) (Cost effective).

Click Review + create > Create.

Create Container:

Go to the new Storage Account resource.

On the left menu, select Data storage > Containers.

Click + Container.

Name: tfstate

Public Access: Private (no anonymous access).

Click Create.

Step 3: Configure Terraform Backend
Tell Terraform to lock and store the state file in the container created above.

Action: Create terraform/backend.tf and paste the following:

Terraform

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-devops"
    storage_account_name = "tfstatestoredevops8642" # Update if you changed the name
    container_name       = "tfstate"
    key                  = "resume-repo.terraform.tfstate"
  }
}
Phase 2: Terraform Infrastructure Deployment
Goal: specific infrastructure resources (Static Web App and Monitoring) using code.

Step 4: Define Azure Resources
Action: Create terraform/modules/static-app/main.tf.

This code provisions your Resource Group, Application Insights for monitoring, and the Static Web App hosting service.

Terraform

# terraform/modules/static-app/main.tf

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.app_name}-prod"
  location = var.location
}

# 1. Monitoring: Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.app_name}-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# 2. Hosting: Azure Static Web App (SWA)
resource "azurerm_static_web_app" "resume_swa" {
  name                = "swa-${var.app_name}-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_tier            = "Free"
  sku_size            = "Free"
}
Note: Ensure you also create a variables.tf file to define var.app_name and var.location, and an outputs.tf to export the SWA Deployment Token.

Step 5: Initialize and Apply Terraform
Deploy the infrastructure to Azure.

Navigate: cd terraform

Initialize:

Bash

terraform init
Confirm that the backend initializes successfully.

Plan:

Bash

terraform plan
Review the resources to be created.

Apply:

Bash

terraform apply -auto-approve
Step 6: Configure GitHub Secrets
For GitHub Actions to deploy code to your new Static Web App, it needs the deployment token generated in Step 5.

Get the Token:

Go to Azure Portal > Search for your new Static Web App (swa-devops-resume-prod).

Click Manage deployment token.

Copy the token string.

Add to GitHub:

Go to your Repo on GitHub > Settings > Secrets and variables > Actions.

Click New repository secret.

Name: AZURE_STATIC_WEB_APPS_API_TOKEN

Value: (Paste the token).

Click Add secret.

Phase 3: Frontend Security & Observability
Goal: Implement security headers and link the frontend to the monitoring system.

Step 7: Implement Security Headers
Action: Create src/staticwebapp.config.json.

This file enforces security policies at the edge (Azure CDN).

JSON

{
  "globalHeaders": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;",
    "X-Frame-Options": "DENY",
    "X-Content-Type-Options": "nosniff"
  }
}
Step 8: Embed Application Insights Snippet
Get Instrumentation Key:

From your terraform apply output or Azure Portal (Application Insights > Overview), copy the Instrumentation Key.

Update HTML:

Open src/index.html.

Paste the following script inside the <head> tag:

HTML

<script type="text/javascript">
  var appInsights=window.appInsights||function(a){
    function b(a){c[a]=function(){var b=arguments;c.queue.push(function(){c[a].apply(c,b)})}}
    var c={config:a},d=document,e=window;
    setTimeout(function(){e.appInsights=c;},1);
    c.queue=[];
    for(var f=["trackEvent","trackPageView","trackException","trackTrace","setAuthenticatedUserContext"],g=0;g<f.length;g++)b(""+f[g]);
    return b("loadAndTrackPage"),b("startTrackPage"),b("stopTrackPage"),c
  }({
      instrumentationKey: "PASTE_YOUR_KEY_HERE"
  });
</script>
Phase 4: Automated CI/CD Pipeline
Goal: Automate testing and deployment on every code push.

Step 9: Define CI/CD Workflow
Action: Create .github/workflows/azure-swa.yml.

YAML

name: Build and Deploy DevOps Resume

on:
  push:
    branches: [ main ]
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  # Job 1: Quality Gate (Linting & Testing)
  lint_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm ci # Faster and cleaner than npm install for CI
      - name: Run Linting and Tests
        run: |
          npm run lint
          npm test

  # Job 2: Deployment (Only runs if Job 1 passes)
  build_and_deploy:
    runs-on: ubuntu-latest
    needs: lint_and_test
    name: Build and Deploy to Azure SWA
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
      
      - name: Build and Deploy Static App
        uses: azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/src"      # Folder containing your index.html
          output_location: "dist"   # Folder containing build output
          skip_app_build: true      # Set false if you are building a framework (React/Vue)
Step 10: Commit and Launch
Trigger the pipeline by pushing your code.

Bash

git add .
git commit -m "feat: Initial commit with Terraform, Security config, and CI/CD"
git push origin main
Result: Navigate to the Actions tab in your GitHub repository. You will see the pipeline execute:

Lint/Test: Checks code quality.

Deploy: Pushes the src folder to your live Azure URL.