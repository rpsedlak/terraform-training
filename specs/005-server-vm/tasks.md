# Tasks: Private Server VM

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Select the VM image and operating system.
- [ ] Define the private access method and required network rules.
- [ ] Decide whether the Premium disk applies to the OS disk, a data disk, or both.
- [ ] Select the Premium disk SKU, capacity, and performance settings.
- [ ] Identify supported B-series overrides for the target Azure region.

## Implementation

- [ ] Create one VM and NIC in the servers subnet from feature 003.
- [ ] Set `Standard_B2s_v2` as the default and validate B-series overrides with at least two vCPUs.
- [ ] Configure the approved attached disk as Premium managed storage.
- [ ] Ensure no public IP is associated with the VM or NIC.
- [ ] Apply feature 006 naming rules where permitted.

## Verification

- [ ] Run Terraform formatting and validation.
- [ ] Verify exactly one VM is planned in the servers subnet.
- [ ] Verify the default and override constraints for VM size.
- [ ] Verify the approved Premium disk configuration and no public IP association.
- [ ] Review the plan without applying it and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>