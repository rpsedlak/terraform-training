# Plan: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-15

## Approved Access Revision

Integrate [feature 007](../007-jit-vm-access/plan.md) under ADR-018 instead of feature 004. Use AzureRM-owned inline NSG rules to allow TCP 3389 only from `69.244.159.36/32` before denying all other RDP sources. No AzAPI, licensing checks, JIT policy or manual Bastion-rule removal gate remains. Preserve state isolation and existing OIDC credentials; do not change subscription billing.

## Technical approach

Integrate network foundation (feature 003), server VM (feature 005), naming (feature 006), and source-restricted public access (feature 007) as one Terraform environment. This feature owns shared provider, version, state, identity, and root-module integration. Keep CI orchestration in [feature 001](../001-terraform-ci-pipeline/plan.md).

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Deployment region | East US (`eastus`) ([ADR-011](../001-terraform-ci-pipeline/decisions/ADR-011-east-us-region.md)) | Selected Azure region. |
| Terraform toolchain and state | Terraform 1.16.6, `infra/` root, Azure Blob backend, OIDC ([ADR-013](../001-terraform-ci-pipeline/decisions/ADR-013-terraform-toolchain-and-state.md)) | Reproducible and secure execution. |
| Component integration | Features 003, 005, 006 and 007 | Maintains component ownership and avoids duplicate requirements. |

## Security and operations

- Credentials and permissions: use an approved secure identity with least privilege; never commit credentials.
- State and locking: use the Azure Blob backend and OIDC defined in ADR-013; backend storage is bootstrapped separately.
- Deployment approvals and rollback: use the protected approval flow specified by feature 001; do not apply without explicit authorization.
- Cost and cleanup: review public-IP, VM and disk costs and removal of Bastion before deployment; do not change paid security plans.

## Validation

- Run `terraform fmt -check` and `terraform validate` against `infra/` using the pinned version.
- Review one combined Terraform plan against the acceptance criteria in features 003, 005, 006 and 007.
- Do not run `terraform apply` as part of implementation or verification without explicit user authorization.

## Risks

- An incorrect source IP can prevent RDP access; verify the approved public egress address without widening the allowlist.
- Azure resource availability and cost vary by region and SKU; verify selected choices before plan approval.
- Terraform plans and state may expose sensitive values; restrict access and never commit them.