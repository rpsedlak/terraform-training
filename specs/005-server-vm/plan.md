# Plan: Server VM

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-15

## Approved Access Revision

[Feature 007](../007-jit-vm-access/plan.md) and ADR-018 replace Bastion and JIT with direct public-IP RDP. Attach a Standard static IPv4 public IP to the existing NIC and retain the VM. Terraform owns the NSG allow from `69.244.159.36/32` at priority 100 and TCP 3389 deny from all other sources at 110. No licensing check or access request is needed. All image, size, disk and credential requirements remain unchanged.

## Technical approach

Create one East US Windows Server 2022 Datacenter Azure Edition VM and its network interface in the servers subnet supplied by feature 003. Set `Standard_D2ds_v6` as the VM-size default for development, testing and production under ADR-019; retain B-series overrides with at least two vCPUs. Validate D2ds_v6 without an environment restriction. Match the workflow dispatch and PR-plan fallback defaults to Terraform. Use a Premium SSD P10 OS disk only and a Standard static public IPv4 for source-restricted direct RDP. Retain the subnet NSG association before public-IP attachment.

After Azure OIDC login, retrieve the VM administrator username from Key Vault secret `adminuser` and the password from `adminpassword`. Pass both values to Terraform without printing them. Limit state access because Terraform state contains the VM password.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| VM count and placement | One VM in the servers subnet ([ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md)) | Approved compute footprint. |
| VM size | Default `Standard_D2ds_v6` for all environments; retain B-series overrides with at least two vCPUs ([ADR-019](../001-terraform-ci-pipeline/decisions/ADR-019-shared-d2ds-v6-vm-size.md)) | Testing and production match development. |
| OS disk | Premium SSD P10, no data disk ([ADR-007](../001-terraform-ci-pipeline/decisions/ADR-007-premium-managed-disk.md)) | Approved tier, SKU, and disk role. |
| Public IP | Standard static IPv4 on existing NIC ([ADR-018](../001-terraform-ci-pipeline/decisions/ADR-018-source-restricted-rdp.md)) | Direct access without Bastion or JIT. |
| Image and access | Windows Server 2022 Datacenter Azure Edition; direct public-IP RDP | Preserve the OS and credentials. |
| RDP network rules | TCP 3389 allow from `69.244.159.36/32` at 100; deny all others at 110 | Restrict both public and private-network RDP sources. |
| VM credential source | Azure Key Vault via OIDC ([ADR-015](../001-terraform-ci-pipeline/decisions/ADR-015-vm-credentials-from-key-vault.md)) | Avoids storing VM credentials in GitHub configuration. |

## Security and operations

- Credentials and permissions: use the environment's approved secure deployment identity.
- State and locking: follow feature 002's backend decision.
- Deployment approvals and rollback: use feature 001's protected apply workflow; do not apply during verification.
- Cost and cleanup: review VM and Premium disk cost, retention, and cleanup before deployment.

## Validation

- Verify the D2ds_v6 default and explicit input in all three environments, valid B-series overrides, and rejection of other D-series/undersized inputs. Verify dispatch and PR-plan defaults match.
- Review the plan for VM count, subnet/NSG attachment, image, P10 OS disk, exact RDP allow/deny rules, NIC public IP association and Key Vault credential wiring.
- Run Terraform formatting and validation; do not apply.

## Risks

- Verify image, VM size, and disk availability in East US before deployment.