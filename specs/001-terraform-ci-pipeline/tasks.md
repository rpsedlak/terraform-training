# Tasks: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Specification

- [x] Select GitHub Actions and protected environment reviewers (ADR-012).
- [x] Define sanitized plan review and prohibit sensitive raw plan output in logs.
- [x] Select Azure OIDC/workload identity federation and least-privilege trust conditions (ADR-012).

## Implementation

- [x] Add GitHub Actions pull-request checks for formatting and validation in `infra/`.
- [x] Add a protected privileged-plan job that publishes resource addresses, actions, and changed attribute names, not values.
- [x] Add a manually dispatched apply job restricted to `main` and protected GitHub environments.
- [x] Configure workflow OIDC login and separate plan/apply client ID inputs; exclude fork pull requests.
- [ ] Create the GitHub plan/apply environments, required reviewer rules, and deployment-branch restrictions.
- [ ] Configure Microsoft Entra federated credentials and least-privilege plan/apply roles for each environment.
- [ ] Grant plan/apply identities Key Vault secret-read access only to the VM credential secrets.

## Verification

- [ ] Demonstrate formatting check failure for a formatting violation in `infra/`.
- [ ] Demonstrate validation failure for invalid Terraform configuration.
- [ ] Verify the proposed-change flow exposes a reviewable plan before apply.
- [ ] Verify untrusted changes cannot access deployment credentials or sensitive plan output.
- [ ] Verify apply is blocked until the protected approval is granted.
- [x] Parse both workflow YAML files locally; `actionlint` is not installed.
- [ ] Confirm all acceptance criteria in `spec.md` and record evidence.

## Completion notes

Both workflow YAML files parse locally. `actionlint` is unavailable, and no GitHub Actions run was triggered. GitHub environments/reviewer rules and Microsoft Entra OIDC federation/role assignments must be configured before privileged jobs can run.