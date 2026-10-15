# Plan: Environment Naming

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-14

## Technical approach

Use one `environment` input (`development`, `testing`, or `production`) and derive `d`, `t`, or `p` from a central mapping. Compose names using `<resource-abbreviation>-terraform-training-<environment-code>-eastus-<instance>` where permitted. Preserve Azure-required names and adapt for resource-specific constraints.

ADR-018 retains `pip-server-terraform-training-<environment-code>-eastus-001` for the public IP and removes the JIT policy name and combined-name constraint. Retire Bastion names and preserve existing VM/network names.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Development code | `d` ([ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md)) | Accepted mapping. |
| Testing code | `t` ([ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md)) | Accepted mapping. |
| Production code | `p` ([ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md)) | Accepted mapping. |
| Resource name pattern | Resource abbreviation, workload, environment code, region, instance ([ADR-014](../001-terraform-ci-pipeline/decisions/ADR-014-azure-resource-naming.md)) | Follows Microsoft CAF guidance while retaining the required one-letter code. |

## Security and operations

- Credentials and permissions: environment selection must not carry or expose credentials.
- State and locking: use the shared backend and environment isolation decisions in feature 002.
- Deployment approvals and rollback: follow feature 001's protected environment approval process.
- Cost and cleanup: distinct names should support identifying and cleaning up the intended environment only.

## Validation

- Test that the environment input accepts only the three approved values and derives the correct code.
- Test that invalid environment values are rejected.
- Inspect planned resource names for each environment and verify Azure constraints and reserved names.

## Risks

- Incorrect environment selection can target the wrong resources; validate allowed values and review plans before apply.
- Azure resource naming rules vary; verify every name against the corresponding resource constraints.