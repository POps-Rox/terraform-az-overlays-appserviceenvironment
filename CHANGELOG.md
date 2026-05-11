# Changelog

# v2.0.0 - Phase 1 azurerm 4.x upgrade

Changed (BREAKING)
- Raised `required_version` from `>= 1.9` to `>= 1.10`
- Raised `azurerm` provider constraint from `~> 3.116` to `~> 4.20`
- Added `azapi ~> 2.0` to `required_providers` for fleet alignment
- The example `versions.tf` (`examples/basic/versions.tf`) previously had no
  `terraform { required_providers { … } }` block; one has been added to pin
  matching constraints when running the example standalone.

Audited (no code change required)
- No `enable_https_traffic_only` / `allow_blob_public_access` /
  `enable_rbac_authorization` usage in this module.
- No `private_endpoint_network_policies_enabled` subnet attribute usage.
- No `azurerm_monitor_diagnostic_setting` resources, so no `retention_policy`
  block removals required.
- `azurerm_app_service_environment_v3` is unchanged in 4.x — `cluster_setting`
  blocks, `internal_load_balancing_mode`, and
  `allow_new_private_endpoint_connections` remain valid.

Consumer-facing notes
- `azurerm` 4.x requires an explicit subscription (`ARM_SUBSCRIPTION_ID` env
  var or `subscription_id` in `provider "azurerm"`).

# v1.1.0 - 03/26/2026

Changed
- Raised minimum Terraform version from `>= 1.3` to `>= 1.9`
- Raised minimum azurerm provider version from `~> 3.22` to `~> 3.116`
- Updated popsrox-utils provider constraint to `~> 1.0.4`

# v1.0.0 - 02/03/2024

Added
- Init Source
