# Tasks: Azure Network Foundation

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [x] Select `10.20.0.0/22`, `10.20.0.0/26`, and `10.20.1.0/24`; verify ranges do not overlap.
- [x] Remove virtual network gateway and `GatewaySubnet` per ADR-010.
- [x] Select East US and the servers subnet naming pattern.

## Implementation

- [ ] Define the single East US VNet and approved subnets in Terraform.
- [ ] Ensure no virtual network gateway or `GatewaySubnet` is created.
- [ ] Export or otherwise make the VNet and subnet identifiers available to dependent features.

## Verification

- [ ] Run Terraform formatting and validation using the approved version.
- [ ] Verify planned VNet/subnet counts, CIDR containment, and non-overlap.
- [ ] Verify subnet CIDRs and confirm no gateway resource or subnet is planned.
- [ ] Review the plan without applying it and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>