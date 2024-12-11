output "webapp_url" {
  value = azurerm_linux_web_app.taskboardWebApp.default_hostname
}

output "webapp_ips" {
  value = azurerm_linux_web_app.taskboardWebApp.outbound_ip_address_list
}