# ADR-013: Pin Terraform and Use Azure Blob State

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The environment needs a reproducible Terraform toolchain and shared remote state for local and CI workflows.

## Decision

- Use Terraform 1.16.6, the latest stable release on 2026-10-14; pin the CLI version in the repository and workflow.
- Use one root module under `infra/`, with resource declarations grouped by feature. Do not introduce child modules until there is a concrete reuse requirement.
- Use AzureRM provider major version 4 and commit `.terraform.lock.hcl` to pin the selected provider build.
- Store state in the Azure Storage account `dizzyterraform20261014` and blob container `tfstate`, using the `azurerm` backend, Microsoft Entra ID authentication, and OIDC in CI. Use `tftraining-<environment>.tfstate` as the blob key, with a distinct key for each environment.
- Provision the state storage account and container separately before initializing the environment root module. Grant the deployment identity only the required storage data-plane role.

## Consequences

- Local and CI workflows use the same pinned Terraform CLI and provider lock file.
- Azure Blob Storage provides remote state locking; credentials and state are not stored in the repository.
- State backend bootstrap and its identifiers are prerequisites to running Terraform.

## References

- [Terraform releases](https://releases.hashicorp.com/terraform/)
- [Terraform `azurerm` backend](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [Terraform version constraints](https://developer.hashicorp.com/terraform/language/block/terraform#required_version)