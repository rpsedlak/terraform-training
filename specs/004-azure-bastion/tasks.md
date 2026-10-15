# Tasks: Azure Bastion

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Select the Bastion SKU and verify regional availability and requirements.
- [ ] Select the public IP configuration and document access controls.
- [ ] Confirm the Bastion subnet allocation with feature 003.

## Implementation

- [ ] Add the Azure Bastion resource to the shared Terraform environment.
- [ ] Associate it with `AzureBastionSubnet` in the VNet from feature 003.
- [ ] Apply environment naming rules from feature 006 where permitted.

## Verification

- [ ] Run Terraform formatting and validation.
- [ ] Verify the plan places Bastion in the correct VNet and subnet.
- [ ] Verify selected SKU and public IP settings meet approved decisions.
- [ ] Review without applying and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>