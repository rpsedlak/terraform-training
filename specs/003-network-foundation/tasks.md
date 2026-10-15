# Tasks: Azure Network Foundation

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Choose the VNet and subnet CIDR ranges and verify they do not overlap.
- [ ] Select gateway type and subnet sizes; verify all ranges meet Azure requirements.
- [ ] Confirm the servers subnet resource name.

## Implementation

- [ ] Define the single `/22` VNet and required subnets in Terraform.
- [ ] Deploy the Standard SKU virtual network gateway into `GatewaySubnet`.
- [ ] Export or otherwise make the VNet and subnet identifiers available to dependent features.

## Verification

- [ ] Run Terraform formatting and validation using the approved version.
- [ ] Verify planned VNet/subnet counts, CIDR containment, and non-overlap.
- [ ] Verify gateway SKU/type and subnet association satisfy the approved decisions.
- [ ] Review the plan without applying it and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>