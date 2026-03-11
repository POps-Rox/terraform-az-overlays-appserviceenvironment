# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


#---------------------------------------------------------
# Azure Region Lookup
#----------------------------------------------------------
module "mod_azure_region_lookup" {
  source  = "github.com/POps-Rox/tf-az-overlays-azregionslookup"

  azure_region = "eastus"
}

resource "azurerm_resource_group" "ase-rg" {
  name     = "ase-service-rg"
  location = module.mod_azure_region_lookup.location_cli
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_network" "ase-vnet" {
  depends_on = [
    azurerm_resource_group.ase-rg
  ]
  name                = "ase-service-network"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.ase-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "ase-snet" {
  depends_on = [
    azurerm_resource_group.ase-rg,
    azurerm_virtual_network.ase-vnet
  ]
  name                 = "ase-service-subnet"
  resource_group_name  = azurerm_resource_group.ase-rg.name
  virtual_network_name = azurerm_virtual_network.ase-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "ase-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_security_group" "ase-nsg" {
  depends_on = [
    azurerm_resource_group.ase-rg,
  ]
  name                = "ase-service-nsg"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.ase-rg.name
  tags = {
    environment = "test"
  }
}

resource "azurerm_log_analytics_workspace" "ase-log" {
  depends_on = [
    azurerm_resource_group.ase-rg
  ]
  name                = "ase-service-log"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.ase-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "test"
  }
}

