# Tasks: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Specification

- [x] Select GitHub Actions and protected environment reviewers (ADR-012).
- [x] Define sanitized plan review and prohibit sensitive raw plan output in logs.
- [x] Select Azure OIDC/workload identity federation and least-privilege trust conditions (ADR-012).

## Implementation

- [x] Align manual VM-size default and PR-plan fallback to `Standard_D2ds_v6` for all environments under ADR-019; workflow tests verify both values and existing input propagation.
- [x] Retire JIT pricing/policy/operator permission prerequisites under ADR-018; retain existing network, compute, state and Key Vault role requirements. No Azure RBAC or billing changes were performed.
- [x] Add GitHub Actions pull-request checks for formatting and validation in `infra/`.
- [x] Add a protected privileged-plan job that publishes resource addresses, actions, and changed attribute names, not values.
- [x] Add a manually dispatched apply job restricted to `main` and protected GitHub environments.
- [x] Add environment and VM-size dispatch inputs; pass the selected VM size to plan and apply.
- [x] Configure workflow OIDC login and separate plan/apply client ID inputs; exclude fork pull requests.
- [ ] Create the GitHub plan/apply environments, required reviewer rules, and deployment-branch restrictions.
- [ ] Configure Microsoft Entra federated credentials and least-privilege plan/apply roles for each environment.
- [ ] Grant plan/apply identities Key Vault secret-read access only to the VM credential secrets.

## Verification

- [x] Reproduce Windows backend initialization failure in run `38830951954`: default PowerShell interpreted the Bash `TF_STATE_KEY=...` assignment as a cmdlet. Add `shell: bash` to both init steps and demonstrate the new regression assertion failing before the fix and passing afterward (10 workflow tests, 74 assertions).
- [ ] Publish the local Windows backend-shell fix and validate it in a protected development workflow. The user chose to publish it themselves; no commit, PR, merge or further retry is authorized for this local fix.
- [ ] Demonstrate formatting check failure for a formatting violation in `infra/`.
- [ ] Demonstrate validation failure for invalid Terraform configuration.
- [ ] Verify the proposed-change flow exposes a reviewable plan before apply.
- [ ] Verify untrusted changes cannot access deployment credentials or sensitive plan output.
- [ ] Verify apply is blocked until the protected approval is granted.
- [x] Test manual VM-size input and propagation to plan/apply in workflow tests.
- [x] Parse both workflow YAML files locally; `actionlint` is not installed.
- [x] Test workflow trigger, OIDC, Key Vault, sanitization, and apply-gate contracts with Ruby tests.
- [x] Verify provider initialization and validation with the committed lockfile on Linux amd64.
- [x] Fix Windows provider checksum failure in Actions job `116739773407`: generate the missing AzureRM 4.81.0 Windows amd64 hash with Terraform 1.16.6 `providers lock -platform=linux_amd64 -platform=windows_amd64`; repeat the command and confirm the lockfile is unchanged.
- [x] Recheck Terraform formatting, readonly initialization, validation, all 13 Terraform tests, and both Ruby suites (18 tests, 111 assertions) after the checksum fix. Local execution was Linux amd64; Windows execution remains to be confirmed by CI.
- [x] Verify same-repository pull-request plans are gated on required Azure configuration.
- [ ] Confirm all acceptance criteria in `spec.md` and record evidence.

## Completion notes

Both workflow YAML files parse locally, and the Ruby tests cover workflow triggers, OIDC, Key Vault, state keys, plan sanitization, apply gating, and Terraform source contracts. Terraform 1.16.6 format, readonly provider initialization, validation, and all 11 Terraform tests pass on Linux amd64. Same-repository pull-request plan jobs now skip when required Azure variables are absent; workflow-dispatched plans still require configuration. The AzureRM lockfile includes the Linux provider package checksum required by CI. `actionlint` is unavailable. GitHub environments/reviewer rules and Microsoft Entra OIDC federation/Key Vault permissions must be configured before privileged jobs can run.