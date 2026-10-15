# Tasks: Private Server VM

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [x] Select the Windows Server 2022 Datacenter Azure Edition image.
- [x] Define Bastion RDP access over the private IP and limit inbound RDP to the Bastion subnet.
- [x] Select a Premium SSD P10 OS disk only; no data disk.
- [x] Keep `Standard_B2s_v2` as default and allow B-series overrides with at least two vCPUs.

## Implementation

- [ ] Create one VM and NIC in the servers subnet from feature 003.
- [ ] Set `Standard_B2s_v2` as the default and validate B-series overrides with at least two vCPUs.
- [ ] Configure the OS disk as Premium SSD P10 and create no data disk.
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