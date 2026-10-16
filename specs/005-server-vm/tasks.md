# Tasks: Server VM

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Shared VM Size Revision: ADR-019

- [x] Approve `Standard_D2ds_v6` as the default for development, testing and production; retain valid B-series overrides.
- [x] Update the spec/plan and supersede the B2s_v2 default and development-only exception before implementation.
- [x] Align Terraform validation/defaults and workflow dispatch/PR-plan defaults.
- [x] Test default and explicit D2ds_v6 acceptance across all environments, permitted B-series overrides and invalid SKUs.
- [x] Run focused checks and record actual results here.
- [ ] Separately resolve production approval-environment naming and verify quota before any authorized deployment. This revision does not deploy resources.

The earlier size decisions and production preflight entries below are historical; ADR-019 supersedes their development-only restriction and production VM-size decision blocker, not the GitHub environment-name blocker.

Verification on 2026-10-15 using Terraform 1.16.6 on macOS arm64:

- `terraform -chdir=infra test`: 14 passed, 0 failed; default and explicit D2ds_v6 covered for all three environments, alongside valid B-series and invalid/undersized size checks.
- `ruby tests/workflows_test.rb`: 10 tests, 74 assertions, no failures; dispatch default, PR fallback and selected-input propagation verified.
- `terraform -chdir=infra fmt -check -recursive`, readonly backend-free initialization and `terraform validate`: pass.
- `ruby tests/terraform_source_test.rb`: 8 tests, 39 assertions, no failures.
- README/specification local links and `git diff --check`: pass.

No deploy, quota request, environment renaming, state mutation, commit or PR was performed. These are configuration and offline-test results, not a claim of production/testing capacity or successful live provisioning.

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

## Production Deployment Preflight

- The user requested production deployment. Local source and remote `main` match commit `82aeb76709e2640858374408c5bfd05c308a1beb`; no deployment was active. The production resource group `rg-terraform-training-p-eastus-001` does not exist.
- The workflow selects `terraform-plan-production` and `terraform-apply-production`, but GitHub has configured environments `terraform-plan-prod` and `terraform-apply-prod`. The existing apply alias has required reviewers and branch protection, and both aliases contain the required Azure/backend configuration keys. No production run was dispatched because doing so could select an unintended, unprotected environment.
- East US `standardBsv2Family` quota is 0 used / 0 limit, so the default `Standard_B2s_v2` cannot provision. The development-only `Standard_D2ds_v6` exception was not extended to production.
- The already-supported `Standard_B4ms` is available in East US without SKU restrictions. Its `standardBSFamily` quota is 0 used / 10 limit, and total regional vCPU quota is 4 used / 10 limit, sufficient for this four-vCPU option at preflight time.
- Requested decisions on mapping the workflow to the existing protected production aliases and selecting B4ms were skipped. Neither change was authorized. Deployment remains blocked pending those decisions or user-provided protected full-name environments and increased Bsv2 quota.
- No workflow, VM-size input, GitHub environment, OIDC identity, quota, Azure resource or state was changed; no commit, PR, approval submission or deployment was performed. Development and testing were not targeted.