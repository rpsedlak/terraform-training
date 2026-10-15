# Tasks: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [x] Select GitHub Actions and protected environment reviewers (ADR-012).
- [x] Define sanitized plan review and prohibit sensitive raw plan output in logs.
- [x] Select Azure OIDC/workload identity federation and least-privilege trust conditions (ADR-012).

## Implementation

- [ ] Add GitHub Actions pull-request checks for formatting and validation in `infra/`.
- [ ] Add a protected privileged-plan job that publishes only a sanitized summary.
- [ ] Add an apply job restricted to `main` and a GitHub environment with required reviewers.
- [ ] Configure Azure OIDC federation with least-privilege plan/apply roles and fork-PR exclusion.

## Verification

- [ ] Demonstrate formatting check failure for a formatting violation in `infra/`.
- [ ] Demonstrate validation failure for invalid Terraform configuration.
- [ ] Verify the proposed-change flow exposes a reviewable plan before apply.
- [ ] Verify untrusted changes cannot access deployment credentials or sensitive plan output.
- [ ] Verify apply is blocked until the protected approval is granted.
- [ ] Confirm all acceptance criteria in `spec.md` and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>