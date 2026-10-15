# Feature: Terraform CI Pipeline

**Status:** Approved
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

Terraform changes need repeatable checks before they can be reviewed or deployed. The project uses GitHub Actions to safely validate, plan, and gate deployment of the Azure environment specified in [002 Azure Environment](../002-azure-environment/spec.md).

## Goals

- Validate Terraform changes automatically before deployment.
- Make plan output reviewable and prevent unapproved infrastructure changes from being applied.
- Document a repeatable GitHub Actions workflow with protected apply approval and short-lived Azure authentication.

## Non-goals

- Defining or implementing the Azure resources; those requirements belong to [002 Azure Environment](../002-azure-environment/spec.md).
- Applying infrastructure automatically from an unreviewed change.
- Storing cloud credentials or Terraform state in the repository.

## User stories

- As a contributor, I want formatting and validation checks on Terraform changes so that basic errors are found before review.
- As a reviewer, I want to inspect a plan before infrastructure changes are applied so that the impact is understood and authorized.
- As a maintainer, I want deployment credentials and permissions handled outside source control so that secrets are not exposed in the repository.

## Requirements

- The pipeline runs formatting and validation checks against the Terraform root module specified by [002 Azure Environment](../002-azure-environment/spec.md).
- GitHub Actions runs formatting and validation on pull requests. Fork pull requests receive no Azure OIDC token or deployment credentials.
- A privileged plan is generated only in a protected GitHub environment; authorized reviewers can inspect a sanitized plan summary before apply.
- Apply runs only from `main` after required reviewers approve the protected GitHub environment.
- Manual deployment dispatch accepts a VM-size input and passes it to both plan and apply; Terraform validates the environment/size combination.
- Azure authentication uses GitHub OIDC and Microsoft Entra workload identity federation, as decided in [ADR-012](decisions/ADR-012-github-actions-deployment.md).
- Backend identifiers are supplied as non-secret configuration; credentials and Terraform state are not committed to source control.
- The pipeline reports the result of each required check.

## Acceptance criteria

- [ ] A formatting violation in `infra/` causes the pull-request check to fail.
- [ ] Invalid Terraform configuration in `infra/` causes validation to fail.
- [ ] A privileged plan is reviewable by authorized reviewers before apply, without raw sensitive values in logs.
- [ ] Fork pull requests cannot obtain Azure OIDC tokens or deployment credentials.
- [ ] Apply is blocked unless it runs from `main` and the protected environment approval succeeds.
- [ ] The manually dispatched VM size is used consistently for plan and apply; invalid environment/size combinations fail validation.
- [ ] CI does not commit credentials or state files or expose sensitive plan output to untrusted users.

## Constraints and assumptions

- The environment's resources and naming rules are defined by [002 Azure Environment](../002-azure-environment/spec.md); this feature covers only CI behavior.
- CI jobs must use least-privilege permissions and must not expose secrets to untrusted pull requests.
- GitHub Actions and its protected approval process are defined in [ADR-012](decisions/ADR-012-github-actions-deployment.md).
- The Terraform root module, state backend, and identity are defined in [ADR-013](decisions/ADR-013-terraform-toolchain-and-state.md) and feature 002.

## Open questions

None. Implementation configuration values are tracked as tasks, not unresolved architecture decisions.