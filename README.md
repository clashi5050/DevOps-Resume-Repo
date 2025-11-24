Cloud DevOps Resume Challenge ☁️ 🚀
A portfolio project demonstrating Infrastructure as Code (IaC), CI/CD automation, and Cloud Architecture. This repository contains the code to deploy a personal resume website to Azure Static Web Apps, secured with custom headers and monitored via Application Insights, entirely managed by Terraform.

🏗 Architecture

Shutterstock
Explore

The Data Flow:

Developer pushes code to GitHub main branch.

GitHub Actions triggers the CI/CD pipeline.

Job 1 (CI): Installs Node.js dependencies, runs linting/tests.

Job 2 (CD): Deploys the artifacts to Azure Static Web Apps.

Infrastructure: Terraform manages the state of the Resource Groups, Monitoring, and Hosting resources in Azure.

📂 Project Structure
Bash

.
├── .github/workflows/   # CI/CD Pipeline Configuration (YAML)
├── src/                 # The Frontend Website (HTML/CSS/JS)
├── terraform/           # Infrastructure as Code
│   ├── modules/         # Reusable Terraform Modules
│   │   └── static-app/  # Main application logic
│   ├── main.tf          # Root configuration
│   ├── variables.tf     # Variable definitions
│   ├── outputs.tf       # Deployment outputs (URLs, Keys)
│   └── backend.tf       # Remote State configuration
├── package.json         # Node.js config for CI pipeline compliance
└── README.md            # Documentation
🛠 Prerequisites
Before running this project, ensure you have the following:

Azure Account (Free tier works).

Azure CLI installed and logged in (az login).

Terraform CLI installed.

GitHub Account.

🚀 Getting Started
Phase 1: Remote State Setup (One-time Setup)
Terraform needs a place to store its "state" file so teams can collaborate. We use Azure Blob Storage for this.

Create a Resource Group in Azure named rg-tfstate-devops.

Create a Storage Account (unique name) inside that group.

Create a Blob Container named tfstate inside that storage account.

Update terraform/backend.tf with your specific storage account name.

Phase 2: Infrastructure Deployment
Clone the repo:

Bash

git clone https://github.com/your-username/devops-resume-repo.git
cd devops-resume-repo/terraform
Initialize Terraform:

Bash

terraform init
Create a terraform.tfvars file: To avoid hardcoding values, create this file in the terraform/ folder:

Terraform

location = "eastus2"
app_name = "devops-resume"
Plan and Apply:

Bash

terraform plan
terraform apply
Phase 3: CI/CD & Security Configuration
Once Terraform finishes, it will output sensitive keys. You need these to connect GitHub to Azure.

Retrieve the Deployment Token:

Bash

terraform output -raw deployment_token
Copy this value.

Configure GitHub Secrets:

Go to your Repo Settings -> Secrets and variables -> Actions.

Create a new secret: AZURE_STATIC_WEB_APPS_API_TOKEN.

Paste the token value.

Configure Application Insights (Frontend):

Run terraform output -raw instrumentation_key.

Paste this key into src/index.html where indicated.

🔄 The Pipeline (CI/CD)
This project uses GitHub Actions for automation.

Trigger: Pushes to the main branch.

Quality Gate: Runs npm ci and npm run lint to ensure code quality.

Deployment: Uses the azure/static-web-apps-deploy action to push the src folder to the live site.

To trigger a deployment: Simply make a change to the HTML/CSS and push:

Bash

git add .
git commit -m "feat: Updated resume content"
git push origin main
🔍 Verification
Check the URL: After deployment, run:

Bash

cd terraform
terraform output -raw site_url
Open the URL in your browser.


Check Monitoring: Go to the Azure Portal -> Application Insights. You will see live traffic data, page views, and performance metrics from your site.

📜 Future Improvements
[ ] Add a custom domain (e.g., www.yourname.com).

[ ] Implement a Visitor Counter using Azure Functions (API).

[ ] Add Cypress for End-to-End testing in the pipeline.

✍️ Author
Clayton Shields Jr.

LinkedIn Profile

Portfolio/Website

Built with ❤️ using Terraform and Azure.
