# Tasks: Private Server VM

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Specification

- [x] Select the Windows Server 2022 Datacenter Azure Edition image.
- [x] Define Bastion RDP access over the private IP and limit inbound RDP to the Bastion subnet.
- [x] Select a Premium SSD P10 OS disk only; no data disk.
- [x] Keep `Standard_B2s_v2` as default and allow B-series overrides with at least two vCPUs.
- [x] Select Key Vault secrets `adminuser` and `adminpassword` for the username and password (ADR-015).

## Implementation

- [x] Create one Windows VM and NIC in the servers subnet from feature 003.
- [x] Set `Standard_B2s_v2` as the default and validate B-series overrides with at least two vCPUs.
- [x] Configure the OS disk as Premium SSD P10 and create no data disk.
- [x] Ensure no public IP is associated with the VM or NIC; allow RDP only from Bastion subnet.
- [x] Retrieve VM credentials from Key Vault through Azure OIDC in both plan and apply jobs; mask values and keep them out of GitHub secrets.
- [x] Apply feature 006 naming rules where permitted.

## Verification

- [x] Run Terraform formatting, validation, and offline mock-provider tests.
- [ ] Verify exactly one VM is planned in the servers subnet.
- [ ] Verify the default and override constraints for VM size.
- [x] Verify the approved P10 OS disk, RDP NSG allow/deny rules, and no NIC public IP in offline tests.
- [x] Verify the workflow reads `adminuser` and `adminpassword` after Azure OIDC login and masks both values.
- [ ] Verify plan/apply identities have only the required Key Vault secret-read access and Terraform state permissions.
- [ ] Review the plan without applying it and record evidence.

## Completion notes

Terraform formatting, validation, offline resource tests, and workflow YAML parsing pass. Key Vault access, Azure plan verification, and East US image/SKU availability remain unverified because the Azure identity and Key Vault are not configured in this workspace. No apply was run.