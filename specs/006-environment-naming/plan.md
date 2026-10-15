# Plan: Environment Naming

**Related spec:** [spec.md](spec.md)  
**Status:** Draft  
**Last updated:** 2026-10-14

## Technical approach

Use one environment selection input and derive the corresponding single-letter code from a central mapping. Compose that code into names for resources where permitted. Preserve Azure-required names. Finalize the naming pattern and input interface before implementation.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Development code | `d` ([ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md)) | Accepted mapping. |
| Testing code | `t` ([ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md)) | Accepted mapping. |
| Production code | `p` ([ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md)) | Accepted mapping. |
| Full resource name pattern | Unresolved | Code position and separators are not yet decided. |

## Security and operations

- Credentials and permissions: environment selection must not carry or expose credentials.
- State and locking: use the shared backend and environment isolation decisions in feature 002.
- Deployment approvals and rollback: follow feature 001's protected environment approval process.
- Cost and cleanup: distinct names should support identifying and cleaning up the intended environment only.

## Validation

- Test that all three environment selections derive the correct code.
- Test that invalid environment values are rejected.
- Inspect planned resource names for each environment and verify Azure constraints and reserved names.

## Risks

- Incorrect environment selection can target the wrong resources; validate allowed values and review plans before apply.
- Azure resource naming rules vary; verify every name against the corresponding resource constraints.