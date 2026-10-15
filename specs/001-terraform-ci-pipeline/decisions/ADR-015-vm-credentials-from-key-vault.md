# ADR-015: Retrieve VM Credentials from Azure Key Vault

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The Windows server VM requires administrator credentials for provisioning. These credentials must not be stored as GitHub secrets or variables.

## Decision

- Retrieve the VM administrator username and password from Azure Key Vault after the workflow authenticates to Azure through OIDC.
- Use `adminuser` as the Key Vault secret name for the username.
- Use `adminpassword` as the Key Vault secret name for the password.
- Supply the Key Vault name through the non-secret GitHub variable `AZURE_KEY_VAULT_NAME`.
- Do not print retrieved values in workflow logs.

## Consequences

- Plan and apply identities require narrowly scoped permission to read the two selected Key Vault secrets.
- Terraform state contains the VM password because AzureRM manages the Windows administrator credential as part of the VM resource. State access must be limited to trusted deployment identities and protected reviewers.
- Key Vault secret values are not stored in GitHub secrets or variables.