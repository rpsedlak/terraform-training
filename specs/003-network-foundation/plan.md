# Plan: Azure Network Foundation

**Related spec:** [spec.md](spec.md)  
**Status:** Draft  
**Last updated:** 2026-10-14

## Technical approach

Define one Azure VNet and the gateway, Bastion, and servers subnets in Terraform. Add the Standard SKU virtual network gateway to its reserved subnet. Share the VNet and subnet identifiers with features 004 and 005. Do not select address ranges or gateway type until the open questions are resolved.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Azure deployment | Azure with Terraform ([ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md), [ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md)) | Cross-cutting approved platform and tool. |
| VNet topology | One `/22` VNet ([ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md)) | Approved topology. |
| Subnets | `GatewaySubnet`, `AzureBastionSubnet`, and `/24` servers subnet ([ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md)) | Reserves network segments for environment components. |
| Gateway type and CIDRs | Unresolved | Require user decisions and Azure compatibility checks. |

## Security and operations

- Credentials and permissions: use an approved secure Terraform identity; do not commit credentials.
- State and locking: follow the shared backend decision in feature 002.
- Deployment approvals and rollback: use the protected CI process in feature 001; no apply during verification.
- Cost and cleanup: verify gateway and address-space costs and document cleanup before deployment.

## Validation

- Verify the VNet is `/22` and the servers subnet is `/24`.
- Verify subnet CIDRs are non-overlapping and each lies within the VNet CIDR.
- Verify gateway and Bastion subnet sizing against current Azure requirements.
- Review the plan for the exact subnet names and gateway association; do not apply.

## Risks

- Invalid or overlapping CIDRs prevent deployment or connectivity; allocate and verify all ranges before implementation.
- Gateway SKU/type requirements may affect subnet sizing and regional availability.