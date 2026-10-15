# ADR-017: Replace Bastion With Public-IP JIT Access

**Status:** JIT requirements superseded by [ADR-018](ADR-018-source-restricted-rdp.md); Bastion removal and server public-IP naming retained. The text below records the historical decision, not current JIT requirements.
**Date:** 2026-10-15

## Decision

Replace Basic Bastion with one Standard static IPv4 address on the existing server NIC and Terraform-managed Defender for Cloud JIT for TCP 3389, maximum three hours. Operators select My IP for each request. Native JIT allows authorized requesters to choose other sources; this restriction is procedural, not technically enforced.

This supersedes [ADR-004](ADR-004-azure-bastion.md), [ADR-008](ADR-008-no-server-public-ip.md), and the Bastion-subnet portion of [ADR-003](ADR-003-azure-network-topology.md). Preserve all other VM/network decisions and CIDRs. Feature 004 is historical; [feature 007](../../007-jit-vm-access/spec.md) owns access requirements.

Extend ADR-013's toolchain with a pinned Azure/azapi provider. Extend ADR-014 naming with `pip-server-terraform-training-<environment-code>-eastus-001`, distinct from the old Bastion public IP, and the short JIT policy name `default` to satisfy the combined policy/VM name limit of 56 characters.

## Consequences

- Removing Bastion avoids its dedicated provisioning and ongoing service cost, but savings depend on subscription-wide P2 coverage and the user's Azure offer.
- JIT requires paid Defender for Servers Plan 2, enabled at subscription scope. Environment Terraform must verify coverage, not enable/manage subscription pricing. User approved this prerequisite and code implementation, not billing activation or deployment.
- No permanent public RDP rule is allowed. Remove old Bastion rules before JIT setup; Defender owns dynamic NSG rules and Terraform owns desired policy, not requests.
- Keep protected OIDC deployments and Key Vault credentials. Document distinct policy administration and request-initiation RBAC.
- JIT expiry blocks new connections; existing sessions may persist. Validate live connectivity and Terraform drift only after explicit deployment authorization.

## References

- [JIT prerequisites and operation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)
- [Plan 2 scope](https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers-select-plan)
- [JIT resource schema](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/2020-01-01/locations/jitnetworkaccesspolicies)
- [Defender pricing](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)