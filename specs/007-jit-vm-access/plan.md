# Plan: Source-Restricted Public VM Access

**Related spec:** [spec.md](spec.md)
**Status:** Approved
**Last updated:** 2026-10-15

## Technical Approach

Retain the existing resource addresses for the VM, NIC, network and subnet. Remove Bastion and its dedicated subnet/public IP. Add a distinctly named server public IP and associate it only after the servers subnet NSG association exists. Preserve current CIDRs and compute settings.

Under ADR-018, replace JIT with two Terraform-owned inline NSG rules: `AllowRdpFromTrustedPublicIp`, priority 100, TCP 3389, source `69.244.159.36/32`; then `DenyRdpFromOtherSources`, priority 110, TCP 3389, source `*`. Use inbound direction, wildcard source port and destination address, and no other inbound allow. The deny overrides Azure's default virtual-network allow for RDP. Keep the source in a central local, not a freely overridable input.

Delete `infra/jit.tf`, the resource-group prerequisite dependency, JIT output, client-config-derived ID locals and policy name. Remove AzAPI from required providers, provider configuration and lockfile; retain AzureRM and its version/checksums. No subscription pricing data source or resource remains. Keep automatic AzureRM provider registration disabled and existing ARM OIDC authentication unchanged.

## Migration and Security

The previous JIT change was not deployed in this work. Existing Bastion inline rules can be replaced by the new authoritative inline rules in a reviewed Terraform plan; no manual rule-clearing or P2 setup is required. Retain the NSG association throughout. Review Bastion removal and the in-place NIC/NSG updates before any apply.

If a policy was separately deployed, do not drop its provider while its resources remain in state: use a separately approved transition with the old provider available to remove the JIT policy and its owned rules, refresh/reconcile state, then use this configuration. Confirm no external policy recreates JIT rules before granting Terraform authoritative NSG ownership. No removal or state manipulation is run during implementation.

Use a direct RDP client from public source `69.244.159.36` with existing Key Vault credentials. No access request, expiry procedure, JIT RBAC or paid security plan is required. Other Azure security services and billing are outside scope. On access failure, verify the source egress IP and credentials; never widen the source to `*`.

## Validation

Reuse existing Terraform mock-provider and Ruby contract tests. Remove AzAPI data mocks and licensing/JIT cases. Assert the two exact inbound rules, source `/32`, priority order, TCP-only port 3389, explicit deny, NSG/subnet/NIC relationships, public IP and existing compute/credential requirements for all environments. Assert no JIT resource, gates, output or provider remains. Run formatting, readonly initialization, validation, Terraform tests and both Ruby suites. Retain macOS arm64 and Linux amd64 AzureRM checksums.

Do not apply or retrieve real credentials. Live plan review and connectivity from approved/disallowed sources remain pending until separately authorized. Record actual checks in [tasks.md](tasks.md).