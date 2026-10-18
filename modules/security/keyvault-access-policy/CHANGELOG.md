# Changelog

## Unreleased

- Verify that both the existing Key Vault reference and access policy resource
  use the latest stable `2026-05-15` API. The Azure REST API specification
  includes the access-policy update operation in that stable version. Microsoft
  Learn's template reference currently lists `2026-02-01` as its latest stable
  version and `2026-03-01-preview` as preview; the newer stable provider
  specification is used instead.
- Update the key permission documentation to include the rotation and release
  permissions supported by the current API, and clarify that `policyName` is
  the `add`, `remove`, or `replace` operation.
- Add the missing module-local PSRule test template. No module parameters or
  outputs change, and no breaking changes were identified. Add a narrowly
  scoped PSRule configuration for its false-positive finding that
  `secretsPermissions` is a sensitive deployment parameter.

- [Key Vault access policy API reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults/accesspolicies)
- [Key Vault API change log](https://learn.microsoft.com/azure/templates/microsoft.keyvault/change-log/vaults/accesspolicies)
- [Azure REST API specification, stable `2026-05-15`](https://github.com/Azure/azure-rest-api-specs/blob/e4072190a9191cd6b5832b158fe8e88a3c8e1aee/specification/keyvault/resource-manager/Microsoft.KeyVault/KeyVault/stable/2026-05-15/openapi.json)
