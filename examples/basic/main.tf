
module "mod_app_service_environment" {
  source = "../.."
  #source  = "github.com/POps-Rox/tf-az-overlays-appserviceenvironment"
  #version = "~> 1.0"

  depends_on = [azurerm_resource_group.ase-rg]

  existing_resource_group_name = azurerm_resource_group.ase-rg.name
  location                     = module.mod_azure_region_lookup.location_cli
  environment                  = "public"
  deploy_environment           = "dev"
  org_name                     = "anoa"
  workload_name                = "ase"

  ase_subnet_name      = azurerm_subnet.ase-snet.name
  virtual_network_name = azurerm_virtual_network.ase-vnet.name

  # Tags
  add_tags = local.tags # Tags to be applied to all resources
}