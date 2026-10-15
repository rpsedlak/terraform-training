# Plan: Private Server VM

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-14

## Technical approach

Create one East US Windows Server 2022 Datacenter Azure Edition VM and its network interface in the servers subnet supplied by feature 003. Set `Standard_B2s_v2` as the VM-size default and validate B-series overrides with at least two vCPUs. Use a Premium SSD P10 OS disk only, no VM public IP, and RDP through Bastion's private connection.

After Azure OIDC login, retrieve the VM administrator username from Key Vault secret `adminuser` and the password from the secret named by `TF_VM_ADMIN_PASSWORD_SECRET_NAME`. Pass both values to Terraform without printing them. Limit state access because Terraform state contains the VM password.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| VM count and placement | One VM in the servers subnet ([ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md)) | Approved compute footprint. |
| VM size | Default `Standard_B2s_v2`; B-series override with at least two vCPUs ([ADR-006](../001-terraform-ci-pipeline/decisions/ADR-006-b-series-vm-size.md)) | Approved default and minimum. |
| OS disk | Premium SSD P10, no data disk ([ADR-007](../001-terraform-ci-pipeline/decisions/ADR-007-premium-managed-disk.md)) | Approved tier, SKU, and disk role. |
| Public IP | None on VM or NIC ([ADR-008](../001-terraform-ci-pipeline/decisions/ADR-008-no-server-public-ip.md)) | Prevents direct public IP exposure. |
| Image and access | Windows Server 2022 Datacenter Azure Edition; RDP through Bastion on private IP | Approved OS and management path. |
| RDP network rule | Allow only from `AzureBastionSubnet` | Restricts management access to Bastion. |
| VM credential source | Azure Key Vault via OIDC ([ADR-015](../001-terraform-ci-pipeline/decisions/ADR-015-vm-credentials-from-key-vault.md)) | Avoids storing VM credentials in GitHub configuration. |

## Security and operations

- Credentials and permissions: use the environment's approved secure deployment identity.
- State and locking: follow feature 002's backend decision.
- Deployment approvals and rollback: use feature 001's protected apply workflow; do not apply during verification.
- Cost and cleanup: review VM and Premium disk cost, retention, and cleanup before deployment.

## Validation

- Verify the default and allowed/denied VM size overrides.
- Review the plan for VM count, subnet attachment, image, P10 OS disk, RDP source, absence of VM/NIC public IP association, and Key Vault credential wiring.
- Run Terraform formatting and validation; do not apply.

## Risks

- Verify image, VM size, and disk availability in East US before deployment.