terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.12.0"

    }
  }
}
provider "azurerm" {
  subscription_id = "79d904d1-d5d4-45bf-a049-0f7392866159"
  features {

  }
}

resource "random_integer" "ri" {
  min = 1
  max = 50000
}

resource "azurerm_resource_group" "mitkorg" {
  location = "West Europe"
  name     = "ContactsBookRG-${random_initiger.ri.result}"
}
resource "azurerm_service_plan" "mitkowbsp" {
  name                = "mitkowbsp"
  resource_group_name = azurerm_resource_group.mitkorg.name
  location            = azurerm_resource_group.mitkorg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}
resource "azurerm_linux_web_app" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.mitkorg.name
  location            = azurerm_resource_group.mitkorg.location
  service_plan_id     = azurerm_resource_group.mitkorg.id

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