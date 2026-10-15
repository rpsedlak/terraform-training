# Tasks: Azure Network Foundation

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Specification

- [x] Select `10.20.0.0/22`, `10.20.0.0/26`, and `10.20.1.0/24`; verify ranges do not overlap.
- [x] Remove virtual network gateway and `GatewaySubnet` per ADR-010.
- [x] Select East US and the servers subnet naming pattern.

## Implementation

- [x] Define the single East US VNet and approved subnets in Terraform.
- [x] Ensure no virtual network gateway or `GatewaySubnet` is created.
- [x] Reference VNet and subnet resources directly from Bastion and VM resources in the shared root module.

## Verification

- [x] Run Terraform formatting, initialization without backend, and validation using Terraform 1.16.6.
- [x] Verify approved CIDR locals and containment in offline mock-provider tests.
- [ ] Verify planned VNet/subnet counts, CIDR containment, and non-overlap.
- [ ] Verify subnet CIDRs and confirm no gateway resource or subnet is planned.
- [ ] Review the plan without applying it and record evidence.

## Completion notes

Terraform formatting, validation, and offline CIDR tests pass. Live Azure subnet allocation and plan review remain unverified because Azure authentication and state bootstrap are not configured. No apply was run.