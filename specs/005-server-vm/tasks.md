# Tasks: Private Server VM

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Specification

- [x] Select the Windows Server 2022 Datacenter Azure Edition image.
- [x] Define Bastion RDP access over the private IP and limit inbound RDP to the Bastion subnet.
- [x] Select a Premium SSD P10 OS disk only; no data disk.
- [x] Keep `Standard_B2s_v2` as default and allow B-series overrides with at least two vCPUs.

## Implementation

- [x] Create one Windows VM and NIC in the servers subnet from feature 003.
- [x] Set `Standard_B2s_v2` as the default and validate B-series overrides with at least two vCPUs.
- [x] Configure the OS disk as Premium SSD P10 and create no data disk.
- [x] Ensure no public IP is associated with the VM or NIC; allow RDP only from Bastion subnet.
- [x] Apply feature 006 naming rules where permitted.

## Verification

- [x] Run Terraform formatting, validation, and offline mock-provider tests.
- [ ] Verify exactly one VM is planned in the servers subnet.
- [ ] Verify the default and override constraints for VM size.
- [x] Verify the approved P10 OS disk, RDP NSG allow/deny rules, and no NIC public IP in offline tests.
- [ ] Review the plan without applying it and record evidence.

## Completion notes

Terraform formatting, validation, and offline tests for size constraints, image, P10 OS disk, RDP rules, and NIC public-IP absence pass. East US image/SKU availability and an Azure plan remain unverified. No apply was run.