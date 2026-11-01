# Changelog

## Unreleased

- Apply the configured virtual network link resolution policy to the deployed link.
- Keep the private DNS zone resource APIs on the latest stable `2024-06-01` version.
- Add the missing module assertion block and Bicep validation tests for required and full parameter scenarios.
- Add a module CI workflow, complete parameter examples, and refresh the module README for the current interface.

The private DNS zone module already uses the latest stable Azure REST API versions for the zone, A records, VNet links, and lock resources. No breaking interface changes are introduced in this update.
