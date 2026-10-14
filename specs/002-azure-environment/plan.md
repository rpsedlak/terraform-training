# Plan: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Status:** Draft  
**Last updated:** 2026-10-14

## Technical approach

Implement one Terraform root module for the environment after the blocking decisions in `spec.md` are resolved. Define the Azure virtual network and required subnets, the Standard SKU virtual network gateway, Azure Bastion, and exactly one private server VM with the approved size and Premium managed disk. Derive resource-name environment codes from a single environment input, while preserving Azure-mandated names. Keep CI orchestration in [feature 001](../001-terraform-ci-pipeline/plan.md).

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Cloud target | Microsoft Azure ([ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md)) | Approved deployment platform. |
| Infrastructure as code | Terraform ([ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md)) | Approved provisioning tool. |
| Network topology | One `/22` VNet; gateway, Bastion, and `/24` servers subnets ([ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md)) | Approved network layout. |
| Bastion | Deploy in `AzureBastionSubnet` ([ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md)) | Approved access service. |
| Server | Exactly one VM in the servers subnet ([ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md)) | Approved compute count and placement. |
| VM size | Default `Standard_B2s_v2`; input override constrained to B-series with at least two vCPUs ([ADR-006](../001-terraform-ci-pipeline/decisions/ADR-006-b-series-vm-size.md)) | Approved default and minimum size constraint. |
| VM disk | Premium managed disk ([ADR-007](../001-terraform-ci-pipeline/decisions/ADR-007-premium-managed-disk.md)) | Approved storage tier. |
| Server public IP | None attached to the VM or its NIC ([ADR-008](../001-terraform-ci-pipeline/decisions/ADR-008-no-server-public-ip.md)) | Prevents direct public-IP access to the server. |
| Environment code | `d`, `t`, or `p` for development, testing, or production ([ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md)) | Provides consistent environment identification. |

## Security and operations

- Credentials and permissions: use an approved secure identity with least privilege; never commit credentials.
- State and locking: choose a remote backend and locking before enabling shared applies.
- Deployment approvals and rollback: use the protected approval flow specified by feature 001; do not apply without explicit authorization.
- Cost and cleanup: document Azure costs, retention, and cleanup for the selected gateway, Bastion, VM, and disk SKUs before deployment.

## Validation

- Run `terraform fmt -check` on the completed root module.
- Run `terraform validate` with the selected Terraform version.
- Review a Terraform plan and verify resource counts, subnet associations, VM size constraints, disk tier, public-IP absence, and environment naming against `spec.md`.
- Do not run `terraform apply` as part of implementation or verification without explicit user authorization.

## Risks

- CIDR allocation or undersized subnets can make gateway or Bastion deployment fail; resolve ranges and verify Azure requirements before implementation.
- Azure resource availability and cost vary by region and SKU; verify selected choices before plan approval.
- Terraform plans and state may expose sensitive values; restrict access and never commit them.