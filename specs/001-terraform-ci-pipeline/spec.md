# Feature: Terraform CI Pipeline

**Status:** Draft  
**Owner:** <name or team>  
**Last updated:** 2026-10-14

## Problem

Terraform changes need repeatable checks before they can be reviewed or deployed. This training project needs a defined, safe pipeline workflow for deploying to Microsoft Azure without assuming a specific CI vendor.

## Goals

- Validate Terraform changes automatically before deployment.
- Make plan output reviewable and prevent unapproved infrastructure changes from being applied.
- Document the pipeline decisions so the example can be adapted to a chosen CI platform.

## Non-goals

- Selecting specific Azure services before the infrastructure scope is defined.
- Applying infrastructure automatically from an unreviewed change.
- Storing cloud credentials or Terraform state in the repository.

## User stories

- As a contributor, I want formatting and validation checks on Terraform changes so that basic errors are found before review.
- As a reviewer, I want to inspect a plan before infrastructure changes are applied so that the impact is understood and authorized.
- As a maintainer, I want deployment credentials and permissions handled outside source control so that secrets are not exposed in the repository.

## Requirements

- The pipeline checks formatting and runs Terraform validation for the configured Terraform root module.
- A plan is generated for review on proposed changes, subject to the selected CI platform's security constraints.
- Applying a plan requires an explicit approval gate and is not triggered by an unreviewed change.
- Provider credentials and backend configuration are supplied through an approved secure mechanism, not committed to source control.
- The pipeline reports the result of each required check.

## Acceptance criteria

- [ ] A formatting violation causes the relevant CI check to fail.
- [ ] Invalid Terraform configuration causes validation to fail.
- [ ] A proposed change produces a plan that can be reviewed before apply.
- [ ] An apply cannot run without the agreed approval gate.
- [ ] No credentials, state files, or generated plan artifacts containing sensitive data are committed to the repository.

## Constraints and assumptions

- The deployment target is Microsoft Azure ([ADR-001](decisions/ADR-001-azure-deployment.md)), and the environment will be provisioned using Terraform ([ADR-002](decisions/ADR-002-terraform-deployment.md)). The Azure services and root module scope, CI provider, Terraform version, state backend, and execution identity are undecided.
- CI jobs must use least-privilege permissions and must not expose secrets to untrusted pull requests.
- Terraform commands and configuration details will be selected after the platform, resource scope, and version decisions are approved.

## Open questions

- [ ] Which CI platform should this training example use, and who owns the approval gate?
- [ ] Which Terraform version and Azure resource scope should the example target?
- [ ] Which remote state backend, locking mechanism, and identity model should be demonstrated?
- [ ] Should plan output be published as a CI artifact, and what retention and access controls are required?