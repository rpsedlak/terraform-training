# Tasks: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Decide and approve the CI platform and protected approval mechanism.
- [ ] Decide how plans will be reviewed, access-controlled, and retained.
- [ ] Decide the secure identity mechanism and least-privilege permissions for approved applies.

## Implementation

- [ ] Add CI checks for formatting and validation of the Terraform root module in feature 002.
- [ ] Add plan generation for proposed changes without exposing sensitive output to untrusted jobs.
- [ ] Add a protected approval gate before the apply job.
- [ ] Configure secure deployment identity and least-privilege permissions.

## Verification

- [ ] Demonstrate formatting check failure for a formatting violation in feature 002's Terraform root module.
- [ ] Demonstrate validation failure for invalid Terraform configuration.
- [ ] Verify the proposed-change flow exposes a reviewable plan before apply.
- [ ] Verify untrusted changes cannot access deployment credentials or sensitive plan output.
- [ ] Verify apply is blocked until the protected approval is granted.
- [ ] Confirm all acceptance criteria in `spec.md` and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>