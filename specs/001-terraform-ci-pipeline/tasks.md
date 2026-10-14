# Tasks: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Decide and approve the CI platform and protected approval mechanism.
- [ ] Decide and approve the Terraform version, cloud provider, and root module scope.
- [ ] Decide and approve the state backend, locking, and execution identity.
- [ ] Define safe plan review, artifact access, and retention expectations.

## Implementation

- [ ] Add the minimal Terraform root module and ignore rules required by the approved scope.
- [ ] Add CI checks for formatting and Terraform validation.
- [ ] Add plan generation and review behavior for proposed changes.
- [ ] Add an explicitly approved apply path using the selected secure identity mechanism.

## Verification

- [ ] Demonstrate formatting check failure for a formatting violation.
- [ ] Demonstrate validation failure for invalid Terraform configuration.
- [ ] Verify the proposed-change flow exposes a reviewable plan before apply.
- [ ] Verify apply is blocked until the protected approval is granted.
- [ ] Confirm secrets, state, and sensitive plan output are not committed or exposed to untrusted jobs.
- [ ] Confirm all acceptance criteria in `spec.md` and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>