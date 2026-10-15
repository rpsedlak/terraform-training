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
- [ ] Separately review an authenticated plan and authorize deployment before testing live connectivity. No billing or Azure resource changes are authorized now.

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

No Azure API calls, credential retrieval, deployment, state mutation or billing changes were performed for ADR-018. The pre-existing untracked root state file was left untouched. Live plan review and connectivity remain unverified; do not infer live security behavior solely from mocks. Linux binaries were not executed locally.