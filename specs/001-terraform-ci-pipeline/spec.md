# Feature: Terraform CI Pipeline

**Status:** Draft  
**Owner:** <name or team>  
**Last updated:** 2026-10-14

## Problem

Terraform changes need repeatable checks before they can be reviewed or deployed. This training project needs a defined, safe pipeline workflow for the Azure environment specified in [002 Azure Environment](../002-azure-environment/spec.md), without assuming a specific CI vendor.

## Goals

- Validate Terraform changes automatically before deployment.
- Make plan output reviewable and prevent unapproved infrastructure changes from being applied.
- Document the pipeline decisions so the example can be adapted to a chosen CI platform.

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
- Proposed changes generate a Terraform plan for review, subject to the selected CI platform's security controls.
- Applying a plan requires an explicit protected approval and must not be triggered by an unreviewed or untrusted change.
- Provider credentials and backend configuration are supplied through an approved secure mechanism, not committed to source control.
- The pipeline reports the result of each required check.

## Acceptance criteria

- [ ] A formatting violation causes the relevant CI check to fail.
- [ ] Invalid Terraform configuration causes validation to fail.
- [ ] A formatting violation in the environment Terraform root module causes the CI check to fail.
- [ ] Invalid Terraform configuration causes validation to fail.
- [ ] A proposed change produces a plan that reviewers can inspect before apply.
- [ ] An untrusted change cannot access deployment credentials or trigger apply.
- [ ] Apply is blocked until the protected approval is granted.
- [ ] CI does not commit credentials or state files, or expose sensitive plan output to untrusted users.

## Constraints and assumptions

- The environment's resources and naming rules are defined by [002 Azure Environment](../002-azure-environment/spec.md); this feature covers only CI behavior.
- CI jobs must use least-privilege permissions and must not expose secrets to untrusted pull requests.
- The CI platform, protected environment/approval mechanism, and handling of plan output remain undecided.

## Open questions

- [ ] Which CI platform should this training example use, and who owns the approval gate?
- [ ] Which CI platform and protected approval mechanism should this training example use?
- [ ] How should plan output be presented, access-controlled, and retained?
- [ ] Which secure identity mechanism should CI use for approved applies?