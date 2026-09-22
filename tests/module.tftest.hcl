mock_provider "azurerm" {
  mock_resource "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/privateDnsZones/ase-generated.appserviceenvironment.net"
    }
  }

  mock_data "azurerm_resource_group" {
    defaults = {
      name     = "rg-existing"
      location = "eastus"
    }
  }

  mock_data "azurerm_subnet" {
    defaults = {
      id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/ase-subnet"
      address_prefixes = ["10.10.0.0/24"]
    }
  }

  mock_data "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-test"
    }
  }

  mock_data "azurerm_app_service_environment_v3" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Web/hostingEnvironments/ase-generated"
      internal_inbound_ip_addresses = ["10.10.0.4"]
    }
  }

  mock_data "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/networkSecurityGroups/ase-generated-nsg"
    }
  }
}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "ase-generated"
    }
  }
}

variables {
  location                     = "eastus"
  environment                  = "public"
  deploy_environment           = "dev"
  workload_name                = "web"
  org_name                     = "contoso"
  virtual_network_name         = "vnet-test"
  ase_subnet_name              = "ase-subnet"
  existing_resource_group_name = "rg-existing"
  add_tags = {
    costCenter = "cc123"
  }
}

run "existing_resource_group_defaults" {
  command = apply

  override_module {
    target = module.mod_azregions
    outputs = {
      location_short = "eus"
      location_cli   = "eastus"
    }
  }

  assert {
    condition     = length(data.azurerm_resource_group.rgrp) == 1
    error_message = "Existing resource group data source should be enabled when create_ase_resource_group is false."
  }

  assert {
    condition     = length(module.mod_scaffold_rg) == 0
    error_message = "Resource group module should be disabled when create_ase_resource_group is false."
  }

  assert {
    condition     = local.ase_name == "ase-generated"
    error_message = "Generated ASE name should be used when no custom ASE name is provided."
  }

  assert {
    condition     = local.resource_group_name == "rg-existing"
    error_message = "Existing resource group name should pass through to local.resource_group_name."
  }

  assert {
    condition     = local.location == "eastus"
    error_message = "Existing resource group location should pass through to local.location."
  }

  assert {
    condition     = azurerm_app_service_environment_v3.ase.tags.costCenter == "cc123"
    error_message = "Custom tags should be merged onto the ASE resource."
  }

  assert {
    condition     = azurerm_app_service_environment_v3.ase.tags.deployedBy == "AzureNoOpsTF [default]"
    error_message = "Default tags should be merged onto the ASE resource."
  }

  assert {
    condition     = azurerm_private_dns_zone_virtual_network_link.ase_vnet_link.private_dns_zone_id == azurerm_private_dns_zone.ase_dns_zone.id
    error_message = "Private DNS virtual network link should use the zone ID."
  }

  assert {
    condition     = azurerm_private_dns_a_record.ase_wildcard_a_rec.private_dns_zone_id == azurerm_private_dns_zone.ase_dns_zone.id
    error_message = "Private DNS A records should use the zone ID."
  }
}

run "custom_ase_name_takes_precedence" {
  command = apply

  variables {
    ase_custom_name = "ase-custom"
  }

  override_module {
    target = module.mod_azregions
    outputs = {
      location_short = "eus"
      location_cli   = "eastus"
    }
  }

  assert {
    condition     = local.ase_name == "ase-custom"
    error_message = "Non-empty ase_custom_name should take precedence over the generated name."
  }

  assert {
    condition     = azurerm_app_service_environment_v3.ase.name == "ase-custom"
    error_message = "ASE resource should use the custom ASE name."
  }
}

run "empty_custom_ase_name_falls_through" {
  command = apply

  variables {
    ase_custom_name = ""
  }

  override_module {
    target = module.mod_azregions
    outputs = {
      location_short = "eus"
      location_cli   = "eastus"
    }
  }

  assert {
    condition     = local.ase_name == "ase-generated"
    error_message = "Empty ase_custom_name should fall through to the generated name."
  }
}

run "created_resource_group_enabled" {
  command = apply

  variables {
    create_ase_resource_group    = true
    custom_resource_group_name   = "rg-created"
    existing_resource_group_name = null
  }

  override_module {
    target = module.mod_azregions
    outputs = {
      location_short = "eus"
      location_cli   = "eastus"
    }
  }

  override_module {
    target = module.mod_scaffold_rg
    outputs = {
      resource_group_name     = "rg-created"
      resource_group_location = "eastus"
    }
  }

  assert {
    condition     = length(data.azurerm_resource_group.rgrp) == 0
    error_message = "Existing resource group data source should be disabled when create_ase_resource_group is true."
  }

  assert {
    condition     = length(module.mod_scaffold_rg) == 1
    error_message = "Resource group module should be enabled when create_ase_resource_group is true."
  }

  assert {
    condition     = local.resource_group_name == "rg-created"
    error_message = "Created resource group module output should feed local.resource_group_name."
  }

  assert {
    condition     = local.location == "eastus"
    error_message = "Created resource group module location should feed local.location."
  }
}
