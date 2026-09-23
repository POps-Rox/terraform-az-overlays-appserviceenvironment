# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_private_dns_zone" "ase_dns_zone" {
  depends_on = [
    azurerm_app_service_environment_v3.ase
  ]
  name                = var.environment == "public" ? "${local.ase_name}.appserviceenvironment.net" : "${local.ase_name}.appserviceenvironment.us"
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "Azure-ASE-Private-DNS-Zone") }, var.add_tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "ase_vnet_link" {
  depends_on = [
    azurerm_private_dns_zone.ase_dns_zone
  ]
  name                 = "ase-vnet-private-zone-link"
  private_dns_zone_id  = azurerm_private_dns_zone.ase_dns_zone.id
  virtual_network_id   = data.azurerm_virtual_network.pe_vnet.id
  registration_enabled = false
  tags                 = merge({ "Name" = format("%s", "Azure-ASE-Private-DNS-Zone") }, var.add_tags, )
}

resource "azurerm_private_dns_a_record" "ase_wildcard_a_rec" {
  depends_on = [
    azurerm_app_service_environment_v3.ase
  ]
  name                = "*"
  private_dns_zone_id = azurerm_private_dns_zone.ase_dns_zone.id
  ttl                 = 300
  records             = [data.azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses[0]]
}

resource "azurerm_private_dns_a_record" "ase_at_a_rec" {
  depends_on = [
    azurerm_app_service_environment_v3.ase
  ]
  name                = "@"
  private_dns_zone_id = azurerm_private_dns_zone.ase_dns_zone.id
  ttl                 = 300
  records             = [data.azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses[0]]
}

resource "azurerm_private_dns_a_record" "ase_scm_a_rec" {
  depends_on = [
    azurerm_app_service_environment_v3.ase
  ]
  name                = "*.scm"
  private_dns_zone_id = azurerm_private_dns_zone.ase_dns_zone.id
  ttl                 = 300
  records             = [data.azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses[0]]
}
