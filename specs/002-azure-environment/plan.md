# Plan: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-14

## Technical approach

Integrate the approved network foundation (feature 003), Azure Bastion (feature 004), server VM (feature 005), and environment naming (feature 006) as one Terraform environment. This feature owns shared provider, version, state, identity, and root-module integration. Keep CI orchestration in [feature 001](../001-terraform-ci-pipeline/plan.md).

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Deployment region | East US (`eastus`) ([ADR-011](../001-terraform-ci-pipeline/decisions/ADR-011-east-us-region.md)) | Selected Azure region. |
| Terraform toolchain and state | Terraform 1.16.6, `infra/` root, Azure Blob backend, OIDC ([ADR-013](../001-terraform-ci-pipeline/decisions/ADR-013-terraform-toolchain-and-state.md)) | Reproducible and secure execution. |
| Component integration | Features 003 through 006 | Maintains component ownership and avoids duplicate requirements. |

## Security and operations

- Credentials and permissions: use an approved secure identity with least privilege; never commit credentials.
- State and locking: use the Azure Blob backend and OIDC defined in ADR-013; backend storage is bootstrapped separately.
- Deployment approvals and rollback: use the protected approval flow specified by feature 001; do not apply without explicit authorization.
- Cost and cleanup: document Azure costs, retention, and cleanup for Bastion, the VM, and its disk before deployment.

## Validation

- Run `terraform fmt -check` and `terraform validate` against `infra/` using the pinned version.
- Review one combined Terraform plan against the acceptance criteria in features 003 through 006.
- Do not run `terraform apply` as part of implementation or verification without explicit user authorization.

## Risks

- Incorrect or undersized subnet allocations can make Bastion deployment fail; verify ranges against current Azure requirements.
- Azure resource availability and cost vary by region and SKU; verify selected choices before plan approval.
- Terraform plans and state may expose sensitive values; restrict access and never commit them.