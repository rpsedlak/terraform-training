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