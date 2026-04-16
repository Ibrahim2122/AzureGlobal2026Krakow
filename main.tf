terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.1.0"
    }
  }
}
provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-user6"
    storage_account_name = "azureevent2026"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

module "keyvault" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=keyvault/v1.0.0"
  keyvault_name = "ibrahimkey1234"
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_rules = []
    ip_rules       = []
  }
  
  resource_group = {
    name     = "rg-user6"
    location = "northeurope"
  }
}

module "service_plan" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=service_plan/v2.0.0"
  # also any inputs for the module (see below)
  app_service_plan_name = "ibrahimplan1234"
  resource_group = {
    name     = "rg-user6"
    location = "northeurope"  
  }
  sku_name = "B1"
  tags = {
    environment = "production"
    project     = "myapp"
  }
}

module "app_service" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=app_service/v1.0.0"
  # also any inputs for the module (see below)
  app_service_name = "ibrahimapp1234"
  app_service_plan_id = module.service_plan.app_service_plan.id
  app_settings = {}
  identity_client_id = "3e6d7df1-32d9-4c60-98b2-61d5cad924f7"
  identity_id = "/subscriptions/4c569ea4-8bfc-4063-9557-390e4b28a153/resourcegroups/rg-user6/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ibrahim-identity"
  resource_group = {
    name     = "rg-user6"
    location = "northeurope"
  }
}