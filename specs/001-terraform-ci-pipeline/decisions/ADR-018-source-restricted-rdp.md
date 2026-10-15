# ADR-018: Direct RDP From One Trusted Public IP

**Status:** Accepted
**Date:** 2026-10-15

## Decision

Connect directly to the existing server's Standard static public IPv4 address over TCP 3389. Terraform owns the servers NSG rules: allow RDP from `69.244.159.36/32` at priority 100, then deny RDP from every other source at priority 110. Retain the subnet NSG association before attaching the public IP.

This supersedes [ADR-017](ADR-017-jit-vm-access.md)'s JIT policy, request procedure, Defender Plan 2 prerequisite, AzAPI provider, policy naming exception, and manual legacy-rule migration gate. Retain its Bastion removal and distinct server public-IP naming decision. ADR-004 and ADR-008 remain superseded; the Bastion subnet in ADR-003 remains retired. [Feature 007](../../007-jit-vm-access/spec.md) now specifies direct source-restricted RDP; its directory name is retained to preserve links.

This also supersedes the Bastion/private-IP access clause in [ADR-005](ADR-005-single-server-vm.md); its VM placement, image and compute footprint remain unchanged.

## Consequences

- Access is continuously available from the approved public IPv4, without a JIT request or expiry. Anyone using that egress IP must still authenticate with the existing VM credentials.
- Other sources, including private-network sources, are explicitly denied TCP 3389. Do not add SSH, WinRM, UDP RDP, or unrestricted inbound rules.
- Remove the JIT policy, pricing checks, prerequisite resource, JIT output and AzAPI provider from active configuration/tests. Do not enable, disable, or otherwise manage Defender billing; no P2 plan is required by this access model.
- Keep the existing VM, NIC, public IP, VNet/subnet CIDRs, image, size, disk, Key Vault credentials, OIDC and protected deployment process unchanged.
- The user must use the approved public egress address. An address change requires a reviewed specification and Terraform update; the address is not a secret or an authentication factor.
- If JIT was deployed outside this code-only work, first obtain separate authorization to remove its policy and Defender-managed rules, refresh state and verify no policy recreates them. Retain the NSG and keep public RDP closed during that migration. Remove unused AzAPI state entries before dropping its provider if necessary; do not abandon a live policy in state.
- No deployment, state mutation, credential retrieval or billing change is authorized by this decision.