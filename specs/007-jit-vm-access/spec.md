# Feature: Source-Restricted Public VM Access

**Status:** Approved
**Owner:** Richard Sedlak
**Last updated:** 2026-10-15

## Problem

Basic Bastion adds cost and provisioning time to this single-server training environment. Replace it with direct public-IP RDP restricted to the user's public IPv4 address, without a JIT service or licensing prerequisite.

## Requirements

- Remove Bastion, its public IP, and its dedicated subnet. Preserve the VNet `10.20.0.0/22`, servers subnet `10.20.1.0/24`, VM, NIC, image, disk, credentials, and size constraints.
- Attach one Standard static IPv4 public IP to the existing server NIC, after its subnet NSG association exists.
- Terraform owns inline servers NSG rules: allow inbound TCP 3389 only from `69.244.159.36/32` at priority 100, then deny TCP 3389 from all other sources at priority 110, including private-network sources.
- Access is always available from the approved source; there is no request or time limit. Do not permit RDP from arbitrary sources or open additional management ports/protocols.
- Remove the JIT policy, pricing data sources, prerequisite gates, JIT output, AzAPI dependency and JIT-specific permissions. No Defender plan or billing change is required or managed.
- Keep protected approvals, OIDC, Key Vault credentials, sanitized review, and environment state isolation unchanged.
- User approved this replacement on 2026-10-15; the earlier JIT/P2 approval is superseded. Deployment is not authorized.

## Acceptance Criteria

- [x] No Bastion host, Bastion subnet, or Bastion public IP remains in the configuration.
- [x] The server NIC references a Standard static IPv4 public IP with a distinct server-specific name.
- [x] The only configured inbound allow is TCP 3389 from `69.244.159.36/32`, before an explicit deny for other RDP sources.
- [x] No active JIT policy, Defender licensing prerequisite, AzAPI dependency, or JIT-specific output remains.
- [x] Offline tests validate exact NSG rules, addressing, naming, public IP, credentials, and existing compute constraints.
- [ ] Review a live plan for in-place updates and removal of any previous policy without unintended VM/network replacement.
- [ ] After separately authorized deployment, RDP succeeds from the approved source and new connections fail from another public IP and private-network sources.

## Non-goals

No deployment, subscription billing change, subnet renumbering, VM replacement, custom access service, or unrelated Defender changes.

## Decisions and Risks

See [ADR-018](../001-terraform-ci-pipeline/decisions/ADR-018-source-restricted-rdp.md), superseding the JIT portion of ADR-017. The source IP must remain stable and is not an identity guarantee. Direct RDP has continuous exposure to clients sharing that egress address; preserve authentication and restrict state/credential access. Prior JIT implementation was code-only; do not assume a live policy exists or change subscription pricing.