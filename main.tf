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

module "managed_identity" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=managed_identity/v1.0.0"
  # also any inputs for the module (see below)
  name = "ibrahim-identity-appservice"
  resource_group = {
    name     = "rg-user6"
    location = "northeurope"
  }
}

module "app_service" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=app_service/v1.0.0"
  # also any inputs for the module (see below)
  app_service_name = "ibrahimapp1234"
  app_service_plan_id = module.service_plan.app_service_plan.id
  app_settings = {
    AZURE_SQL_CONNECTION_STRING = "Server=tcp:${module.mssql_server.server.fully_qualified_domain_name},1433;Initial Catalog=${module.mssql_server.databases["mydb"].name};Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
  identity_client_id = module.managed_identity.managed_identity_client_id
  identity_id = module.managed_identity.managed_identity_id
  resource_group = {
    name     = "rg-user6"
    location = "northeurope"
  }
}

module "mssql_server" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=mssql_server/v1.0.0"
  # also any inputs for the module (see below)
  resource_group = {
    name     = "rg-user6"
    location = "northeurope"
  }
  sql_server_name = "ibrahimsqlserver1234"
  sql_server_admin = "sqladminuser"
  sql_server_version = "12.0"
  databases = [
    {
      name                 = "mydatabase"
      sku                  = "Basic"
      size                 = 2048
      storage_account_type = "Local"
      collation            = "SQL_Latin1_General_CP1_CI_AS"
    }
  ]
}

