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
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.8.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
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

data "azuread_client_config" "current" {}

resource "azuread_application" "example1" {
  display_name = "example1"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "example1" {
  application_id               = azuread_application.example1.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "example1" {
  service_principal_id = azuread_service_principal.example1.object_id
}

resource "azurerm_key_vault_secret" "example1" {
  name         = "example1"
  value        = azuread_service_principal_password.example1.value
  key_vault_id = azurerm_key_vault.example.id
}

resource "azuread_application" "example2" {
  display_name = "example2"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "example2" {
  application_id               = azuread_application.example2.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "example2" {
  service_principal_id = azuread_service_principal.example2.object_id
}

resource "azurerm_key_vault_secret" "example2" {
  name         = "example2"
  value        = azuread_service_principal_password.example2.value
  key_vault_id = azurerm_key_vault.example.id
}

