# Plan: Azure Bastion

**Related spec:** [spec.md](spec.md)  
**Status:** Superseded by [feature 007](../007-jit-vm-access/plan.md) and ADR-018; do not implement this historical plan.
**Last updated:** 2026-10-14

## Technical approach

Add Azure Bastion Basic to the East US VNet from feature 003 and associate it with `AzureBastionSubnet`. Use a Standard static IPv4 public IP. Keep resource names aligned with feature 006 where Azure naming rules permit.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Bastion deployment | Basic SKU in East US, in `AzureBastionSubnet` ([ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md), [ADR-011](../001-terraform-ci-pipeline/decisions/ADR-011-east-us-region.md)) | Lowest-cost dedicated SKU supported in the selected region. |
| VNet and subnet | Feature 003 | Ensures one shared network and consistent subnet allocation. |
| Public IP | Standard SKU, static IPv4 | Required by the selected Basic SKU. |
| Environment naming | Feature 006 | Reuse the shared environment code. |

## Security and operations

- Credentials and permissions: use the environment's approved secure deployment identity.
- State and locking: follow feature 002's backend decision.
- Deployment approvals and rollback: use feature 001's protected apply workflow; do not apply during verification.
- Cost and cleanup: review Basic SKU and public IP charges and delete them when the training environment is no longer needed.

## Validation

- Validate Terraform configuration for Basic SKU and Standard static IPv4 public IP.
- Review the plan to confirm association with the correct VNet and `AzureBastionSubnet`.
- Confirm the server VM remains without a public IP; do not apply.

## Risks

- Validate current Bastion requirements and charges for East US before deployment.