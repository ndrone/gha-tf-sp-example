terraform {
  backend "azurerm" {
    subscription_id      = "acad3507-3c8f-4eaa-9613-13eaae007582"
    resource_group_name  = "tfstate"
    storage_account_name = "dronetfstate"
    container_name       = "tfstate"
    key                  = "sp_rotate.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.83.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "Eastus2"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "droneexamplekeyvault"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set"
    ]
  }
}
