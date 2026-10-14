# Tasks: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Select a VNet base CIDR and non-overlapping subnet CIDRs; confirm gateway and Bastion subnet sizes meet Azure requirements.
- [ ] Decide whether the virtual network gateway is VPN or ExpressRoute.
- [ ] Select the Azure Bastion SKU and its public IP configuration.
- [ ] Select the VM image, operating system, and private access method.
- [ ] Specify which VM disk is Premium managed and select its SKU, capacity, and performance settings.
- [ ] Define the full resource naming pattern around the environment code.
- [ ] Select the Terraform version, remote state backend/locking, and deployment identity.

## Implementation

- [ ] Add the Terraform root module and Azure provider configuration after the specification is approved.
- [ ] Create the `/22` VNet, gateway subnet, `AzureBastionSubnet`, and `/24` servers subnet.
- [ ] Deploy the Standard SKU virtual network gateway and Azure Bastion into their designated subnets.
- [ ] Create exactly one server VM in the servers subnet with the approved B-series size default and override validation.
- [ ] Configure the VM's attached disk as Premium managed storage.
- [ ] Ensure the server VM NIC has no public IP association.
- [ ] Apply the `d`/`t`/`p` environment code to resource names where Azure naming rules permit.

## Verification

- [x] Trace ADR-001 through ADR-009 into the environment requirements and plan.
- [x] Verify local Markdown links resolve and `git diff --check` passes for the specification changes.
- [ ] Run `terraform fmt -check` and `terraform validate` with the selected Terraform version.
- [ ] Verify the plan contains one `/22` VNet and the required subnet layout, including the `/24` servers subnet.
- [ ] Verify the Standard SKU gateway and Azure Bastion are associated with their designated subnets.
- [ ] Verify exactly one VM is in the servers subnet and no public IP is attached to its NIC.
- [ ] Verify `Standard_B2s_v2` is the default and invalid overrides are rejected.
- [ ] Verify the VM's attached disk uses the selected Premium managed SKU.
- [ ] Verify resource names use the selected environment code where permitted and preserve service-mandated names.
- [ ] Review the plan against every acceptance criterion; do not apply without explicit authorization.
- [ ] Record check results and evidence in this task file.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>