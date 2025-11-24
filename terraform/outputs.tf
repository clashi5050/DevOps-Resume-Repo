output "site_url" {
  value = module.static_app_module.swa_default_hostname
}

output "deployment_token" {
  value     = module.static_app_module.swa_api_token
  sensitive = true
}

output "instrumentation_key" {
  value     = module.static_app_module.app_insights_instrumentation_key
  sensitive = true
}