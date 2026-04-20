locals {
  # Naming locals/constants
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_scaffold_rg.*.resource_group_name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_scaffold_rg.*.resource_group_location, [""]), 0)
  ase_name            = coalesce(var.ase_custom_name, data.popsrox_resource_name.ase.result)
  location_short      = module.mod_azregions.location_short
  ase_nsg_name        = "${local.ase_name}-nsg"

}
