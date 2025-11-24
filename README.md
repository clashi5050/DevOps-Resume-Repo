Phase 1: Preparation & GitHub SetupThis phase sets up your code base and secures your infrastructure state.Step 1: Create the Repository Structure (Local Machine & GitHub)Go to GitHub: Open your browser and navigate to https://github.com/new.Create Repo: Give your repository a professional name (e.g., devops-resume-repo). Choose Public visibility.Clone Locally: On your computer, open your terminal (Command Prompt/PowerShell/Terminal) and run:Bashgit clone https://github.com/your-username/devops-resume-repo.git
cd devops-resume-repo
Create Folders: Inside the new folder, create the required structure using your terminal:Bashmkdir src terraform .github
mkdir .github/workflows
mkdir terraform/modules
mkdir terraform/modules/static-app
Result: You now have the skeleton structure ready for code.

Step 2: Set up Azure Remote State (Azure Portal)We need a secure place to store your Terraform state file.Go to Azure Portal: Open a new tab and go to https://portal.azure.com/ and sign in.Create Resource Group:Click "Create a resource" (or the green +).Search for and select "Resource group."Click "Create."Subscription: (Use your default or desired one).Resource group name: rg-tfstate-devopsClick "Review + create," then "Create." (This folder will hold your storage account).Create Storage Account:Back on the Azure Portal Home, click "Create a resource" again.Search for and select "Storage account."Click "Create."Resource Group: Select rg-tfstate-devops.Storage account name: Choose a globally unique name (e.g., tfstatestoredevops8642). Must be lowercase, no spaces.Performance: Select Standard.Redundancy: Select LRS (Locally redundant storage) to save costs.Click "Review + create," then "Create."Create Container:Once the Storage Account is deployed, click "Go to resource."In the menu on the left, click "Containers" (under Data storage).Click "+ Container."Name: tfstatePublic access level: Select Private (no anonymous access).Click "Create."Result: You now have a secure location for your Terraform state.Step 3: Configure Terraform Backend (Local Machine)We need to tell Terraform to use the account you just created.Create the Backend File: On your local machine, inside the terraform directory, create a file named backend.tf and paste the following, replacing the names with your actual account names:Terraformterraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-devops" 
    storage_account_name = "tfstatestoredevops8642" # REPLACE THIS
    container_name       = "tfstate"
    key                  = "resume-repo.terraform.tfstate"
  }
}
Why: This configuration directs Terraform to lock and store the state file in your secure Azure container.

Step 4: Generate SWA Deployment Token (Azure Portal)You need a secure key for GitHub to deploy the code later.
*   Stay in Azure Portal: Click "Create a resource" again.
*   Search for Static Web App and click "Create."
*   Fill in Basic Details (Temporary Setup):Resource Group: Create a New one: rg-resume-deploy
*   Name: devops-resume-temp
*   Hosting plan: Select Free (for cost optimization).
*   Source: Select "Other" (even though we use GitHub, we need the token first).
*   Click "Review + create," then "Create.
*   "Get the Token:Once deployed, click "Go to resource" for the SWA you just created.In the menu on the left, click "Manage deployment token."Click the Copy button next to the long alphanumeric string. Save this token temporarily—you will never see it again!Note: We will use Terraform to create the final SWA later. This token is just a secret key needed for the GitHub Action.
Step 5: Add GitHub Secrets (GitHub Portal)
*   Go to GitHub: Navigate to your devops-resume-repo on GitHub.
*   Go to Secrets: Click the "Settings" tab ->"Security" section -> "Secrets and variables" -> "Actions."Add Secret: Click "New repository secret."Name: AZURE_STATIC_WEB_APPS_API_TOKEN (Must be exact).Secret: Paste the token you copied in Step 4.Click "Add secret."Result: Your CI/CD pipeline now has the secure key it needs to deploy.


Phase 2: Terraform Infrastructure Deployment
Now we write the code to provision the real resources.

Step 6: Define Azure Resources (Local Machine)Create Main Module File: In the directory terraform/modules/static-app/, create a file named main.tf.Paste Core IaC: This code defines your Application Insights and the final Static Web App (SWA).Crucial: You must pass your GitHub repo URL and the token in the code.Terraform# terraform/modules/static-app/main.tf (Conceptual snippet)

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

  # Link to your GitHub repo and main branch
  # The token is passed via the GitHub Action, not here directly for the free tier.
  # For first-time provisioning, we link the repo and let the CI/CD handle the rest.
  # (Note: For this module, you will need corresponding variables.tf and outputs.tf)
}
Step 7: Initialize and Apply Terraform (Local CLI)Open Terminal: Navigate to the main terraform directory.Initialize Terraform: Run this command to load the backend configuration:Bashterraform init
Expect a prompt confirming that the backend is configured to use Azure Blob Storage.Validate Plan: Run this command to see exactly what will be created in Azure:Bashterraform plan
Deploy Resources: Run this command to create the resources (Resource Group, SWA, App Insights):Bashterraform apply
Type yes and press Enter when prompted.Result: Azure services are now provisioned by code!Step 8: Retrieve Instrumentation Key (Local CLI/Azure Portal)Get Key: Once terraform apply finishes, it should output the App Insights key if you correctly defined the outputs (or you can manually go to the Azure Portal $\rightarrow$ App Insights resource $\rightarrow$ "Overview").Copy the value for "Instrumentation Key."Phase 3: Frontend Security & ObservabilityStep 9: Implement staticwebapp.config.json (Local Machine)Create Security File: In the src/ folder, create a file named staticwebapp.config.json.Paste CSP: Paste your security headers here.JSON{
  "globalHeaders": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;",
    "X-Frame-Options": "DENY",
    "X-Content-Type-Options": "nosniff"
  }
}
Why: This file tells the Azure CDN to enforce these security rules.Step 10: Embed Application Insights Snippet (Local Machine)Edit HTML: Open your main entry file (src/index.html or equivalent).Paste Monitoring Script: Find the head section of your HTML and paste the Application Insights script, replacing YOUR_INSTRUMENTATION_KEY with the key from Step 8.HTML<script type="text/javascript">
  var appInsights = window.appInsights || function(a){
    function b(a){c[a]=function(){var b=arguments;c.queue.push(function(){c[a].apply(c,b)})}}
    var c={config:a},d=document,e=window;
    setTimeout(function(){e.appInsights=c;},1);
    c.queue=[];
    for(var f=["trackEvent","trackPageView","trackException","trackTrace","setAuthenticatedUserContext"],g=0;g<f.length;g++)b(""+f[g]);
    return b("loadAndTrackPage"),b("startTrackPage"),b("stopTrackPage"),c
  }({
      instrumentationKey: "YOUR_INSTRUMENTATION_KEY" 
  });
</script>
Why: This starts collecting performance and traffic data from your users' browsers.Phase 4: Automated CI/CD Pipeline ExecutionStep 11: Define CI/CD Workflow (Local Machine)Create Workflow File: In the directory .github/workflows/, create a file named azure-swa.yml.Paste Workflow Logic: This is the core automation pipeline.YAMLname: Build and Deploy DevOps Resume

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  # Step 1: Quality Gate
  lint_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm install # Assumes you have a package.json for linting/testing
      - name: Run Linting and Tests
        run: |
          npm run lint
          npm test

  # Step 2: Deployment
  build_and_deploy:
    runs-on: ubuntu-latest
    needs: lint_and_test # DEPENDS on the quality gate passing
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
          app_location: "/src" # The folder with your index.html/SPA code
          output_location: "dist" # The folder where your build tool puts files (if any)
          skip_app_build: true # Set to false if you use a build script like 'npm run build'
Step 12: Commit and Trigger Pipeline (Local CLI)Stage Files:Bashgit add .
Commit Changes:Bashgit commit -m "feat: Initial commit for Terraform, SWA config, and CI/CD pipeline"
Push to GitHub:Bashgit push origin main
Result: Immediately go to GitHub, click the "Actions" tab, and you will see your pipeline running! It will first run the lint_and_test job, and if successful, the build_and_deploy job will take over, resulting in a live, secure, and automated resume.