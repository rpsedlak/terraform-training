# Tasks: Server VM

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Public Access Revision: ADR-018

- [x] Supersede private-only/Bastion/JIT access with feature 007 and ADR-018; historical checks below describe the former architecture.
- [x] Attach a Standard static IPv4 public IP to the existing NIC with its subnet NSG association as a dependency.
- [x] Replace JIT with TCP 3389 allow from `69.244.159.36/32` and deny from other sources; remove licensing/migration gates and preserve compute/credentials.
- [x] Updated offline tests pass for public IP, exact NSG rules, VM defaults, disk, and credentials.
- [ ] Review the live plan for in-place NIC changes and no VM replacement; test allowed/disallowed-source connectivity only after deployment authorization.

## Specification

- [x] Select the Windows Server 2022 Datacenter Azure Edition image.
- [x] Define Bastion RDP access over the private IP and limit inbound RDP to the Bastion subnet.
- [x] Select a Premium SSD P10 OS disk only; no data disk.
- [x] Keep `Standard_B2s_v2` as default, allow B-series overrides with at least two vCPUs, and record the development-only `Standard_D2ds_v6` quota exception (ADR-016).
- [x] Select Key Vault secrets `adminuser` and `adminpassword` for the username and password (ADR-015).

## Implementation

- [x] Create one Windows VM and NIC in the servers subnet from feature 003.
- [x] Keep `Standard_B2s_v2` as default and support the `Standard_D2ds_v6` development dispatch override.
- [x] Configure the OS disk as Premium SSD P10 and create no data disk.
- [x] Ensure no public IP is associated with the VM or NIC; allow RDP only from Bastion subnet.
- [x] Retrieve VM credentials from Key Vault through Azure OIDC in both plan and apply jobs; mask values and keep them out of GitHub secrets.
- [x] Apply feature 006 naming rules where permitted.

## Verification

- [x] Run Terraform formatting, validation, and offline mock-provider tests.
- [ ] Verify exactly one VM is planned in the servers subnet.
- [x] Verify the default, valid B-series override, development-only `Standard_D2ds_v6`, and invalid size rejection in offline Terraform tests.
- [x] Verify the approved P10 OS disk, RDP NSG allow/deny rules, and no NIC public IP in offline tests.
- [x] Verify the workflow reads `adminuser` and `adminpassword` after Azure OIDC login and masks both values.
- [ ] Verify plan/apply identities have only the required Key Vault secret-read access and Terraform state permissions.
- [ ] Review the plan without applying it and record evidence.

## Completion notes

The first authorized development apply failed because East US `standardBsv2Family` quota is 0. The VNet, subnets, Basic Bastion, public IP, NIC, and NSG are deployed and tracked; the VM is not. ADR-016 records the `Standard_D2ds_v6` development-only exception; the workflow exposes it as a manual dispatch input. No cleanup was run.