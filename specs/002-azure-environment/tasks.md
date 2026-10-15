# Tasks: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Specification

- [x] Approve features 003 through 006 and resolve implementation-blocking decisions.
- [x] Select Terraform 1.16.6, Azure Blob state/OIDC, and the `infra/` root module (ADR-013).

## Implementation

- [x] Add the `infra/` Terraform root module and Azure provider configuration.
- [x] Integrate the approved network, Bastion, server VM, and naming features into one Terraform root.
- [x] Pin Terraform/provider versions and configure the Azure Blob backend interface.
- [x] Integrate the environment with the GitHub Actions workflow in feature 001.
- [ ] Provision the Azure state storage account/container and configure OIDC identities/roles before remote initialization.

## Verification

- [x] Trace ADR-001 through ADR-014 into the environment requirements and plan.
- [x] Verify local Markdown links resolve and `git diff --check` passes for the specification changes.
- [x] Run `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate` with Terraform 1.16.6.
- [x] Run offline mock-provider tests for environment mapping and VM input constraints.
- [ ] Verify the plan contains one `/22` VNet and the required subnet layout, including the `/24` servers subnet.
- [ ] Verify no gateway is deployed and Basic Bastion is associated with `AzureBastionSubnet`.
- [ ] Verify exactly one VM is in the servers subnet and no public IP is attached to its NIC.
- [x] Verify `Standard_B2s_v2` is the default and invalid environment/VM size inputs are rejected by offline tests.
- [x] Verify the configured OS disk uses Premium SSD P10 and the server NIC has no public IP in offline tests.
- [x] Verify environment codes and resource-name examples in offline tests.
- [ ] Review the plan against every acceptance criterion; do not apply without explicit authorization.
- [ ] Record check results and evidence in this task file.

## Completion notes

Terraform 1.16.6 formatting, backend-free initialization, validation, and all seven offline mock-provider tests pass. An Azure-authenticated plan was not run because this environment has no Azure CLI login and the state storage bootstrap is external. No apply was run.