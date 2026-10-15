# Plan: Azure Bastion

**Related spec:** [spec.md](spec.md)  
**Status:** Draft  
**Last updated:** 2026-10-14

## Technical approach

Add Azure Bastion to the shared VNet from feature 003 and associate it with `AzureBastionSubnet`. Use only an approved Bastion SKU and public IP configuration. Keep resource names aligned with feature 006 where Azure naming rules permit.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Bastion deployment | Deploy in `AzureBastionSubnet` ([ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md)) | Accepted architecture decision. |
| VNet and subnet | Feature 003 | Ensures one shared network and consistent subnet allocation. |
| Bastion SKU and public IP | Unresolved | Must be selected before implementation. |
| Environment naming | Feature 006 | Reuse the shared environment code. |

## Security and operations

- Credentials and permissions: use the environment's approved secure deployment identity.
- State and locking: follow feature 002's backend decision.
- Deployment approvals and rollback: use feature 001's protected apply workflow; do not apply during verification.
- Cost and cleanup: evaluate the selected Bastion SKU and public IP cost and cleanup behavior.

## Validation

- Validate Terraform configuration for the selected Bastion SKU and public IP.
- Review the plan to confirm association with the correct VNet and `AzureBastionSubnet`.
- Confirm the server VM remains without a public IP; do not apply.

## Risks

- Bastion SKU or subnet configuration may not satisfy current Azure requirements; validate against the selected region before implementation.
- Public IP configuration and access controls affect exposure and cost; resolve before approval.