# Tasks: Source-Restricted Public VM Access

**Related spec:** [spec.md](spec.md)
**Related plan:** [plan.md](plan.md)
**Status:** In Progress

## Current Revision: ADR-018

The user replaced JIT with direct RDP from `69.244.159.36/32` on 2026-10-15. This section supersedes all JIT/P2 implementation and pending deployment tasks below, which are retained only as historical evidence.

- [x] Approve source-restricted direct RDP and update the specification/plan before implementation.
- [x] Supersede JIT decisions and update all active component specs, plans and documentation.
- [x] Replace Defender ownership with Terraform inline allow/deny rules for TCP 3389.
- [x] Remove JIT resources, prerequisites, outputs, ID locals, provider dependency and related tests.
- [x] Validate exact source, protocols, priorities, denial of other sources and existing compute/network contracts.
- [x] Run readonly initialization, formatting, validation, Terraform/Ruby tests, local links and whitespace checks; record results here.
- [x] User separately authorized development deployment on 2026-10-15; protected workflow completed and its plan/apply summary was checked. No testing/production deployment or subscription billing change was authorized.
- [x] Verify the running development VM, public IP, NSG rules and subnet association; test TCP 3389 from the approved public source.
- [ ] Verify authenticated RDP and rejection from a different public IP and private-network sources; those tests remain pending.

## Historical Evidence

Before ADR-018, the code-only JIT implementation passed 22 mocked Terraform tests, 8 source tests and 10 workflow tests on 2026-10-15. No JIT policy, paid-plan activation, deployment, NSG rule change, access request or state mutation was performed. That implementation and its pending licensing/expiry tasks are now superseded; they are not prerequisites for direct RDP. The untracked root state file remains outside this change.

## Current Evidence

Checks on 2026-10-15 with Terraform 1.16.6 on macOS arm64:

- `terraform -chdir=infra init -backend=false -input=false -lockfile=readonly`: pass; AzureRM remains 4.81.0, AzAPI is absent from configuration and lockfile, and existing provider checksums are retained.
- `terraform -chdir=infra fmt -check -recursive`: pass.
- `terraform -chdir=infra validate`: pass without warnings.
- `terraform -chdir=infra test`: 13 passed, 0 failed. Covers the fixed-source allow and explicit deny, all environments, public-IP/subnet/NSG relationships and existing compute/credential constraints.
- `ruby tests/terraform_source_test.rb`: 8 tests, 39 assertions, no failures; includes absence of JIT/pricing resources, gates, outputs and provider dependency.
- `ruby tests/workflows_test.rb`: 10 tests, 72 assertions, no failures.
- README/specification local links and `git diff --check`: pass.
- No editor diagnostics were reported for the checked implementation files.

During the code-only implementation, no Azure API calls, credential retrieval, deployment, state mutation or billing changes were performed. The root state file was left untouched. Linux binaries were not executed locally. The subsequent explicitly authorized deployment is recorded below.

## Authorized Development Deployment: 2026-10-15

- Source: merged PR #5, `main` commit `310e70ba38f4425eba02b424839eafd61e7f7bfc`.
- Local formatting, readonly initialization, validation, 13 Terraform tests and both Ruby suites passed again. GitHub CI run `38796617920` passed for this commit.
- Dispatched [workflow run 38796983364](https://github.com/rpsedlak/terraform-training/actions/runs/38796983364) with `environment=development` and `vm_size=Standard_D2ds_v6`. Both protected workflow jobs completed successfully; no local apply or approval bypass was performed.
- The plan and apply summary agree: 2 resources added (server NIC and VM), 0 changed, 0 destroyed. Networking/public IP already existed. Apply completed at 19:57 UTC.
- Read-only Azure verification: VM `vm-terraform-training-d-eastus-001` is `Succeeded` and `VM running`, size `Standard_D2ds_v6`, private IP `10.20.1.4`, public IP `20.124.240.101`.
- Public IP is Standard, Static, IPv4. The NIC references that IP and the existing servers subnet `10.20.1.0/24`; the subnet remains associated with the servers NSG. The VNet contains only the servers subnet, and the resource group has no Bastion host.
- Deployed custom NSG rules are TCP 3389 allow from `69.244.159.36/32` at priority 100 and TCP 3389 deny from `*` at priority 110.
- This machine's public egress was `69.244.159.36`; a TCP connection to `20.124.240.101:3389` succeeded. No VM credentials were retrieved locally or printed. A TCP handshake is not proof of authenticated RDP or denial from other sources; those acceptance checks remain open.
- Testing and production were not dispatched. No Defender pricing change or local Terraform state modification was performed. The workflow used the configured environment-isolated remote backend.

## Windows Runner Deployment Attempt: 2026-10-16 UTC

- The user explicitly requested development deployment after PR #6 was merged. Source: `main` commit `b0903d09fa618c6d6527508dd8a1b6b676a1930f`, using the self-hosted Windows runner `tfrunner`.
- Runner `tfrunner` was online and idle with matching labels. GitHub CI run `38830020559` succeeded for this revision; local readonly initialization, formatting, validation, 13 Terraform tests and both Ruby suites passed again.
- Dispatched [workflow run 38830279003](https://github.com/rpsedlak/terraform-training/actions/runs/38830279003) with `environment=development` and `vm_size=Standard_D2ds_v6` at 00:34 UTC.
- The plan job failed at `Read VM administrator credentials from Key Vault` with `bash: command not found`. Checkout, Terraform setup and Azure OIDC authentication succeeded. Remote-state initialization and planning were skipped; the apply job was skipped. No infrastructure apply occurred.
- A read-only Azure check in the approved subscription returned `ResourceGroupNotFound` for `rg-terraform-training-d-eastus-001`; the earlier successful deployment record does not describe the current live environment. Development is currently absent.
- Deployment is blocked until Bash is installed and discoverable by the Windows runner service. Existing backend-initialization steps also contain Bash syntax without an explicit Bash shell and need Windows compatibility review before retrying.
- No runner configuration, workflow implementation, billing settings or local Terraform state was changed during this attempt. No credentials were displayed. Testing and production were not dispatched. A fresh development plan and protected apply remain pending.

## Windows Backend Initialization Retry: 2026-10-16 UTC

- The user requested another development deployment. Dispatched [workflow run 38830951954](https://github.com/rpsedlak/terraform-training/actions/runs/38830951954) from unchanged `main` commit `b0903d0`, with `environment=development` and `vm_size=Standard_D2ds_v6` at 00:41 UTC.
- Bash credential retrieval and OIDC authentication succeeded, confirming the earlier missing-Bash blocker no longer occurs at that step. Remote-state initialization failed because the default Windows PowerShell shell treated the Bash `TF_STATE_KEY=...` assignment as a cmdlet. Planning and apply were skipped; no infrastructure apply occurred.
- Read-only Azure check confirmed `rg-terraform-training-d-eastus-001` does not exist. Development remains absent; testing and production were not targeted.
- Added a local minimal fix: `shell: bash` on both backend-initialization steps, supporting pipeline spec/plan clarification, and a regression assertion in the existing workflow tests. The assertion failed before the fix; all 10 workflow tests (74 assertions) pass afterward, and `git diff --check` passes.
- The user chose to publish the fix themselves. No branch, commit, push, PR, merge, local apply, or further deployment retry was performed. Deployment remains blocked until the corrected workflow reaches `main`. No credentials were displayed or billing settings changed.

## Corrected Windows Workflow Retry: 2026-10-16 UTC

- The user published the Bash-shell fix to `main` commit `0c08cebb0a2c2c0139bc3b71f1b3f8c3493f3c19` and explicitly requested development deployment again.
- Confirmed both backend-initialization steps select Bash, runner `tfrunner` is online, and GitHub CI run `38831272924` succeeded. Local formatting, readonly initialization, validation, 13 Terraform tests, 10 workflow tests (74 assertions) and 8 source tests (39 assertions) passed.
- Dispatched [workflow run 38831385902](https://github.com/rpsedlak/terraform-training/actions/runs/38831385902) with `environment=development` and `vm_size=Standard_D2ds_v6` at 00:46 UTC. No other environment was dispatched and no approval gate was bypassed.
- The new run successfully retrieved Key Vault credentials and initialized remote state under Bash, verifying the fix on the Windows runner. Terraform planning completed, but summary generation failed with `jq: command not found` (exit 127); the apply job was skipped.
- A read-only predeployment check confirmed the development resource group was absent. No VM credentials were retrieved locally or displayed, and the local root state file was not changed.
- The proposed plan contains 8 creates (resource group, VNet, servers subnet, NSG, subnet/NSG association, public IP, NIC and VM), 0 changes and 0 destroys. No Bastion or JIT resource is proposed. The plan was not applied.
- A post-failure read-only check again confirmed `rg-terraform-training-d-eastus-001` does not exist. Development remains undeployed. Testing and production were not dispatched and no subscription pricing changes were made.
- Current blocker: install jq on `tfrunner`, make it discoverable through the runner service's PATH, and restart that service if necessary before retrying. No runner installation, workflow change, commit, PR, approval bypass or local apply was performed during this attempt.

## Successful Windows Development Deployment: 2026-10-16 UTC

- The user explicitly requested another development deployment from `main` commit `ea9c53e651f9f776c2764f0ef03c0c55bf4e9caa`.
- GitHub CI run `38831782090` succeeded for this revision. Local formatting, readonly initialization, validation, 13 Terraform tests, 10 workflow tests (74 assertions) and 8 source tests (39 assertions) passed again.
- Dispatched [workflow run 38831857565](https://github.com/rpsedlak/terraform-training/actions/runs/38831857565) at 00:51 UTC with `environment=development` and `vm_size=Standard_D2ds_v6`, on self-hosted Windows runner `tfrunner`.
- The plan job passed credential retrieval, Bash backend initialization and jq summary generation. The plan proposed 8 creates, 0 changes and 0 destroys: resource group, VNet, servers subnet, NSG, subnet/NSG association, public IP, NIC and VM. No Bastion or JIT resource was proposed.
- Apply waited at the required `terraform-apply-development` gate. The user explicitly approved this plan and continuation. When approval submission was attempted afterward, GitHub no longer had an eligible pending review and the run had already completed; no additional review was submitted and no protection rule was changed or bypassed.
- Both workflow jobs succeeded. Apply completed at 00:54 UTC with 8 resources added, 0 changed and 0 destroyed. No local apply, workflow modification, runner installation, commit or PR was performed during this attempt.
- Read-only Azure verification confirmed VM `vm-terraform-training-d-eastus-001` is `Succeeded` and `VM running`, size `Standard_D2ds_v6`, private IP `10.20.1.4`, public IP `20.127.58.31`. This is the current endpoint, superseding the earlier `20.124.240.101` deployment snapshot.
- The public IP is Standard, Static, IPv4 and attached to the intended server NIC. Its servers subnet is `10.20.1.0/24` with the expected NSG association. No Bastion host is present.
- Deployed custom rules allow inbound TCP 3389 from `69.244.159.36/32` at priority 100 and deny TCP 3389 from all other sources at priority 110.
- This machine's public egress was `69.244.159.36`; a TCP connection to `20.127.58.31:3389` succeeded. Authenticated RDP and denial from alternate public/private sources remain untested. No VM credentials were retrieved locally or displayed.
- Testing and production were not dispatched, no Defender pricing change was made, and the local root state file was not changed. The workflow used the configured development remote backend. The missing-Bash, PowerShell initialization and missing-jq blockers recorded above are resolved for this run.