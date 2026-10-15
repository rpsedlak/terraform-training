# Plan: Azure Network Foundation

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-15

## Approved Access Revision

[ADR-018](../001-terraform-ci-pipeline/decisions/ADR-018-source-restricted-rdp.md) retains Bastion subnet removal from ADR-017. Preserve the existing VNet and servers subnet CIDRs and resource addresses. Only the servers subnet remains; no gateway is added. Feature 007 owns public-IP access restricted to `69.244.159.36/32`.

## Technical approach

Define one East US VNet (`10.20.0.0/22`) and its servers subnet (`10.20.1.0/24`) in Terraform. Share identifiers with features 005 and 007. Do not create a Bastion subnet, virtual network gateway or `GatewaySubnet`.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Azure deployment | Azure with Terraform ([ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md), [ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md)) | Cross-cutting approved platform and tool. |
| Region | East US (`eastus`) ([ADR-011](../001-terraform-ci-pipeline/decisions/ADR-011-east-us-region.md)) | Selected deployment region. |
| VNet topology | `10.20.0.0/22` VNet; no gateway ([ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md), [ADR-010](../001-terraform-ci-pipeline/decisions/ADR-010-no-virtual-network-gateway.md)) | Approved standalone network topology. |
| Subnets | Servers `10.20.1.0/24`; no Bastion subnet | Preserve existing server addressing under ADR-018. |

## Security and operations

- Credentials and permissions: use an approved secure Terraform identity; do not commit credentials.
- State and locking: follow the shared backend decision in feature 002.
- Deployment approvals and rollback: use the protected CI process in feature 001; no apply during verification.
- Cost and cleanup: verify address-space requirements and document cleanup before deployment.

## Validation

- Verify the VNet is `/22` and the servers subnet is `/24`.
- Verify subnet CIDRs are non-overlapping and each lies within the VNet CIDR.
- Verify no Bastion subnet is configured.
- Review the plan for exact subnet names and CIDRs and confirm no gateway resources; do not apply.

## Risks

- Invalid or overlapping CIDRs prevent deployment or connectivity; allocate and verify all ranges before implementation.
- Preserve the servers subnet and its NSG association when removing Bastion resources.