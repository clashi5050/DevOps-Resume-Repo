output "swa_default_hostname" {
  value = azurerm_static_web_app.resume_swa.default_host_name
}

output "swa_api_token" {
  value = azurerm_static_web_app.resume_swa.api_key
}

output "app_insights_instrumentation_key" {
  value = azurerm_application_insights.app_insights.instrumentation_key
}