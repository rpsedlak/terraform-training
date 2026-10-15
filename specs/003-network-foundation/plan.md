# Plan: Azure Network Foundation

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-14

## Technical approach

Define one East US VNet (`10.20.0.0/22`) and its Bastion (`10.20.0.0/26`) and servers (`10.20.1.0/24`) subnets in Terraform. Share the VNet and subnet identifiers with features 004 and 005. Do not create a virtual network gateway or `GatewaySubnet`.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Azure deployment | Azure with Terraform ([ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md), [ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md)) | Cross-cutting approved platform and tool. |
| Region | East US (`eastus`) ([ADR-011](../001-terraform-ci-pipeline/decisions/ADR-011-east-us-region.md)) | Selected deployment region. |
| VNet topology | `10.20.0.0/22` VNet; no gateway ([ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md), [ADR-010](../001-terraform-ci-pipeline/decisions/ADR-010-no-virtual-network-gateway.md)) | Approved standalone network topology. |
| Subnets | `AzureBastionSubnet` `10.20.0.0/26`; servers `10.20.1.0/24` | Approved, non-overlapping ranges. |

## Security and operations

- Credentials and permissions: use an approved secure Terraform identity; do not commit credentials.
- State and locking: follow the shared backend decision in feature 002.
- Deployment approvals and rollback: use the protected CI process in feature 001; no apply during verification.
- Cost and cleanup: verify address-space requirements and document cleanup before deployment.

## Validation

- Verify the VNet is `/22` and the servers subnet is `/24`.
- Verify subnet CIDRs are non-overlapping and each lies within the VNet CIDR.
- Verify `AzureBastionSubnet` sizing against current Azure requirements.
- Review the plan for exact subnet names and CIDRs and confirm no gateway resources; do not apply.

## Risks

- Invalid or overlapping CIDRs prevent deployment or connectivity; allocate and verify all ranges before implementation.
- Azure Bastion subnet requirements may change; validate against current East US requirements before implementation.