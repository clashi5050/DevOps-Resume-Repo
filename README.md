# Terraform Module: Azure Static Web App with Application Insights

This Terraform module provisions the core Azure resources required for hosting a static website with integrated monitoring. It sets up an Azure Resource Group, an Azure Static Web App, and an Azure Application Insights instance.

## Resources Provisioned

*   **`azurerm_resource_group`**: A dedicated resource group to contain all resources for the static web app.
*   **`azurerm_application_insights`**: An Application Insights instance for monitoring the static web app's frontend performance and usage.
*   **`azurerm_static_web_app`**: The Azure Static Web App resource itself, designed for hosting static content and integrating with CI/CD pipelines.

## Usage

To use this module, include it in your root Terraform configuration (e.g., `main.tf` in the parent `terraform/` directory) and provide the necessary input variables.

Example:

```terraform
module "static_resume_app" {
  source = "./modules/static-app" # Path to this module

  app_name = var.app_name
  location = var.location
}
```

## Inputs

The following input variables are required for this module:

| Name       | Description                                        | Type     | Default | Required |
| :--------- | :------------------------------------------------- | :------- | :------ | :------- |
| `app_name` | A unique name for your application, used in naming resources. | `string` | n/a     | yes      |
| `location` | The Azure region where resources will be deployed. | `string` | n/a     | yes      |

*(Note: These variables are assumed based on the `main.tf` snippet provided. A complete module would have a `variables.tf` file defining these explicitly.)*

## Outputs

This module is designed to output key information needed for further configuration, such as CI/CD integration and frontend monitoring. While not explicitly defined in the provided `main.tf` snippet for the module, typical outputs for a static web app module would include:

| Name                | Description                                                               |
| :------------------ | :------------------------------------------------------------------------ |
| `site_url`          | The URL of the deployed Azure Static Web App.                             |
| `deployment_token`  | The deployment token required for GitHub Actions integration.             |
| `instrumentation_key` | The Application Insights instrumentation key for frontend integration.    |

*(Note: These outputs would typically be defined in an `outputs.tf` file within this module.)*