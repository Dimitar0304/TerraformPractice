terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.12.0"

    }
  }
}

resource "random_integer" "ri" {
  min = 1000
  max = 9999
}
provider "azurerm" {
  subscription_id = "79d904d1-d5d4-45bf-a049-0f7392866159"
  features {

  }
}

resource "azurerm_resource_group" "mitkorg" {
  location = "West Europe"
  name     = "ContactsBookRG-${random_integer.ri.result}"
}

resource "azurerm_service_plan" "example" {
  name                = "mitkowsp"
  resource_group_name = azurerm_resource_group.mitkorg.name
  location            = azurerm_resource_group.mitkorg.location
  os_type             = "Linux"
  sku_name            = "F1"
}
resource "azurerm_linux_web_app" "example" {
  name                = "contacts${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.mitkorg.name
  location            = azurerm_resource_group.mitkorg.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {
    application_stack {
      node_version = "16-lts"

    }
    always_on = false
  }
}
resource "azurerm_app_service_source_control" "example" {
  app_id                 = azurerm_linux_web_app.example.id
  repo_url               = "https://github.com/nakov/ContactBook"
  branch                 = "main"
  use_manual_integration = true
}