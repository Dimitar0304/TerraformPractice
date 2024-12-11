terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.11.0"
    }
  }
}
provider "azurerm" {
  subscription_id = "79d904d1-d5d4-45bf-a049-0f7392866159"
  features {

  }
}

resource "random_integer" "ri" {
  min = 1000
  max = 9999
}

resource "azurerm_resource_group" "mitkorg" {
  location = "West Europe"
  name     = "ContactsBookRG-${random_integer.ri.result}"
}

resource "azurerm_service_plan" "TaskBoardPlan" {
  name                = "mitkowsp"
  resource_group_name = azurerm_resource_group.mitkorg.name
  location            = azurerm_resource_group.mitkorg.location
  os_type             = "Linux"
  sku_name            = "F1"
}
resource "azurerm_linux_web_app" "taskboardWebApp" {
  name                = "TaskBoard${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.mitkorg.name
  location            = azurerm_resource_group.mitkorg.location
  service_plan_id     = azurerm_service_plan.TaskBoardPlan.id

  site_config {
    application_stack {
      dotnet_version = "6.0"

    }

    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.taskboardServer.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.taskboardDb.name};User ID=${azurerm_mssql_server.taskboardServer.administrator_login};Password=${azurerm_mssql_server.taskboardServer.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}
resource "azurerm_mssql_server" "taskboardServer" {
  name                         = "sqlserver"
  resource_group_name          = azurerm_resource_group.mitkorg.name
  location                     = azurerm_resource_group.mitkorg.location
  version                      = "12.0"
  administrator_login          = "mitko"
  administrator_login_password = "mitko04"
}
resource "azurerm_mssql_database" "taskboardDb" {
  name           = "taskboardDb"
  server_id      = azurerm_mssql_server.taskboardServer.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = true
}
resource "azurerm_mssql_firewall_rule" "firewallapp" {
  name             = "taskboardFirewall"
  server_id        = azurerm_mssql_server.taskboardServer.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
resource "azurerm_app_service_source_control" "taskboardSourceControl" {
  app_id                 = azurerm_linux_web_app.taskboardWebApp.id
  repo_url               = "https://github.com/Dimitar0304/Azure-Web-App-With-Database-TaskBoard.git"
  branch                 = "main"
  use_manual_integration = true
}