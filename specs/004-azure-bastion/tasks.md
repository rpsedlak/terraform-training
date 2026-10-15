# Tasks: Azure Bastion

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Specification

- [x] Select Basic as the lowest-cost dedicated Bastion SKU available in East US.
- [x] Select Standard static IPv4 public IP and document the server-only no-public-IP scope.
- [x] Confirm `AzureBastionSubnet` allocation `10.20.0.0/26` with feature 003.

## Implementation

- [x] Add the Azure Bastion Basic resource and Standard static public IP.
- [x] Associate it with `AzureBastionSubnet` in the VNet from feature 003.
- [x] Apply environment naming rules from feature 006 where permitted.

## Verification

- [x] Run Terraform formatting, validation, and offline mock-provider tests.
- [ ] Verify the plan places Bastion in the correct VNet and subnet.
- [ ] Verify selected SKU and public IP settings meet approved decisions.
- [ ] Review without applying and record evidence.

## Completion notes

Terraform formatting, validation, and offline SKU/public-IP configuration tests pass. Bastion availability and the resource plan were not checked against an authenticated East US subscription. No apply was run.