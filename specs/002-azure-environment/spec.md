# Feature: Azure Environment

**Status:** Approved
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

The project has accepted architecture decisions for its Azure environment, but those decisions need to be expressed as implementable requirements and verifiable acceptance criteria before Terraform resources are written.

## Goals

- Integrate the approved Azure component features into one Terraform environment.
- Use one region, toolchain, state backend, and deployment identity consistently.
- Keep detailed component requirements in features [003 Network Foundation](../003-network-foundation/spec.md), [004 Azure Bastion](../004-azure-bastion/spec.md), [005 Server VM](../005-server-vm/spec.md), and [006 Environment Naming](../006-environment-naming/spec.md).

## Non-goals

- Defining the CI platform and pipeline workflow; see [001 Terraform CI Pipeline](../001-terraform-ci-pipeline/spec.md).
- Running `terraform apply` or deploying real infrastructure as part of specification work.
- Selecting Azure resource details not established by an accepted ADR unless recorded as a follow-up decision.

## User stories

- As an infrastructure maintainer, I want Terraform to create the approved Azure network and server topology so that the environment is consistent across deployments.
- As an operator, I want the server VM private and reachable through an approved access path so that it is not directly exposed by a public IP.
- As a reviewer, I want Terraform plans to be checked against these requirements so that unapproved infrastructure changes are caught before apply.

## Requirements

- The environment targets Microsoft Azure and is provisioned using Terraform. See [ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md) and [ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md).
- Deploy resources to East US (`eastus`) as decided in [ADR-011](../001-terraform-ci-pipeline/decisions/ADR-011-east-us-region.md).
- Detailed component requirements are owned by features 003 through 006; this feature coordinates their integration into one Terraform environment.
- Use the pinned Terraform toolchain, `infra/` root module, Azure Blob state, and OIDC identity defined in [ADR-013](../001-terraform-ci-pipeline/decisions/ADR-013-terraform-toolchain-and-state.md).
- Integrate features 003 through 006 without duplicating their detailed requirements.
- Do not commit credentials or Terraform state to the repository. Do not apply infrastructure without explicit user authorization.

## Acceptance criteria

- [ ] Features 003 through 006 are implemented and approved against their component acceptance criteria.
- [ ] One Terraform root module in `infra/` integrates the approved features without conflicting resource definitions.
- [ ] The combined plan is valid in East US and satisfies every acceptance criterion in features 003 through 006.
- [ ] The pinned Terraform version, provider lock file, remote state, and OIDC identity are used consistently in local and CI workflows.
- [ ] No credentials, state files, or raw sensitive plan artifacts are committed to the repository.
- [ ] No real infrastructure is applied without explicit user authorization.

## Constraints and assumptions

- The accepted decisions are recorded in ADR-001 through ADR-014 under feature 001's `decisions/` directory; ADR-010 supersedes the gateway portion of ADR-003.
- Azure-required subnet names and naming constraints must be preserved.
- The CI workflow and its protected apply approval are specified separately in feature 001.
- No real deployment occurs while this feature is in Draft or without explicit user authorization.

## Open questions

None. Component decisions and shared toolchain decisions are recorded in the linked ADRs and feature plans.