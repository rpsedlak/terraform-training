# Tasks: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Public Access Revision: ADR-018

- [x] Replace active Bastion/JIT requirements with feature 007 and ADR-018; preserve the historical evidence below.
- [x] Integrate direct public-IP RDP from `69.244.159.36/32` and explicit deny of other sources; remove AzAPI and licensing prerequisites.
- [x] Record final direct-access checks in feature 007: readonly init, format/validate, 13 Terraform tests, 8 source tests, 10 workflow tests, links and whitespace pass.
- [x] Record the separately authorized development deployment and review its actual plan/apply summary; remaining authenticated/other-source connectivity checks are tracked in feature 007.

## Specification

- [x] Approve features 003 through 006 and resolve implementation-blocking decisions.
- [x] Select Terraform 1.16.6, `dizzyterraform20261014/tfstate` with `tftraining-<environment>.tfstate` keys, Azure OIDC, and the `infra/` root module (ADR-013).

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
- [x] Run 13 offline mock-provider tests for environment mapping, resource relationships, and VM input constraints.
- [x] Run 5 source-contract tests for resource inventory, gateway exclusion, private NIC, password sensitivity, and disk scope.
- [x] Run source-contract tests for resource inventory, gateway exclusion, private NIC, and password sensitivity.
- [ ] Verify the plan contains one `/22` VNet and the required subnet layout, including the `/24` servers subnet.
- [ ] Verify no gateway is deployed and Basic Bastion is associated with `AzureBastionSubnet`.
- [ ] Verify exactly one VM is in the servers subnet and no public IP is attached to its NIC.
- [x] Verify `Standard_B2s_v2` default, B-series overrides, development-only `Standard_D2ds_v6`, and invalid environment/VM size inputs in offline tests.
- [x] Verify the configured OS disk uses Premium SSD P10 and the server NIC has no public IP in offline tests.
- [x] Verify environment codes and resource-name examples in offline tests.
- [ ] Review the plan against every acceptance criterion; do not apply without explicit authorization.
- [ ] Record check results and evidence in this task file.

## Completion notes

Terraform 1.16.6 formatting, backend-free initialization, validation, 13 offline mock-provider tests, and 5 source-contract tests pass. An authorized GitHub Actions apply was attempted after development plan approval. Azure rejected the VM because East US `standardBsv2Family` quota is 0; nine other resources remain tracked in remote state. ADR-016 and the workflow input now allow `Standard_D2ds_v6` for development. No cleanup was run.

The development retry was dispatched from merged commit `f12971d` in [workflow run 38679086977](https://github.com/rpsedlak/terraform-training/actions/runs/38679086977). Its successful plan shows only `azurerm_windows_virtual_machine.server` being created with `Standard_D2ds_v6`: 1 to add, 0 to change, 0 to destroy. Read-only Azure checks confirmed the existing VNet `10.20.0.0/22`, Bastion subnet `10.20.0.0/26`, servers subnet `10.20.1.0/24`, Basic Bastion in `Succeeded` state, and server NIC at `10.20.1.4` without a public IP. The protected apply approval was granted and the workflow completed successfully, creating the VM.

### Development teardown: 2026-10-15

The user explicitly requested destruction of the development environment. After confirming no deployment was active and the backend key was `tftraining-development.tfstate`, a local saved Terraform destroy plan was reviewed: 0 to add, 0 to change, 10 to destroy. Every deletion was restricted to `rg-terraform-training-d-eastus-001`; the resource group inventory contained only the training resources and VM OS disk.

Applying that saved plan completed successfully: 0 added, 0 changed, 10 destroyed. `terraform state list` returned no resources, and `az group exists --name rg-terraform-training-d-eastus-001` returned `false`. The shared state account `dizzyterraform20261014` and Key Vault `dizzy-terraform` both remain in `Succeeded` state. Testing and production were not targeted. Temporary sensitive plan artifacts were removed after verification.

### Development Public-IP Deployment: 2026-10-15

After PR #5 was merged, the user explicitly requested development deployment. [Workflow run 38796983364](https://github.com/rpsedlak/terraform-training/actions/runs/38796983364) succeeded from `main` commit `310e70b`, using `development` and `Standard_D2ds_v6`. Both plan and apply reported 2 creates (NIC and VM), 0 changes and 0 destroys; network/public-IP resources already existed.

Azure read-only checks confirmed the VM running with public IP `20.124.240.101`, private IP `10.20.1.4`, the expected static Standard IPv4 resource, servers-subnet NSG association and exact trusted-source RDP allow/deny rules. No Bastion host is present. TCP 3389 was reachable from the approved egress `69.244.159.36`. Authenticated RDP and denial from other source networks remain pending in feature 007. No testing/production deployment or subscription pricing change was performed.