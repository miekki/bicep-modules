# Changelog

## Unreleased

- Verified that the existing Key Vault reference and secret resource use
  `2026-05-15`, the latest stable version in Microsoft's Azure REST API
  specifications. The Microsoft Learn template reference currently lists
  `2026-02-01` as stable and `2026-03-01-preview` as preview, but has not yet
  surfaced the newer stable specification. Keep the stable API; do not replace
  it with the older documented version or adopt the preview.
- The secret resource schemas in the official `2026-02-01` and `2026-05-15`
  specifications have identical properties and required fields. No public
  module parameters or outputs change; no breaking changes were identified.
- Correct and clarify the README, and add the missing `main.test.bicep`
  fixture required by the shared PSRule workflow.

- [Key Vault secret API versions](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults/secrets)
- [Key Vault secret API change log](https://learn.microsoft.com/azure/templates/microsoft.keyvault/change-log/vaults/secrets)
- [Key Vault API versions](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)
- [Microsoft Azure REST API specification for Key Vault 2026-05-15](https://github.com/Azure/azure-rest-api-specs/blob/e4072190a9191cd6b5832b158fe8e88a3c8e1aee/specification/keyvault/resource-manager/Microsoft.KeyVault/KeyVault/stable/2026-05-15/openapi.json)
- [Microsoft Azure REST API specification for Key Vault 2026-02-01](https://github.com/Azure/azure-rest-api-specs/blob/main/specification/keyvault/resource-manager/Microsoft.KeyVault/KeyVault/stable/2026-02-01/openapi.json)
