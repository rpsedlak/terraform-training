# Feature: Environment Naming

**Status:** Approved
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

Resources are deployed into development, testing, and production environments. Their names need a consistent environment identifier without violating Azure naming constraints.

## Goals

- Use the one-letter codes accepted in [ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md).
- Derive the code from the selected environment consistently across Terraform resources.
- Follow the Azure Cloud Adoption Framework naming components in [ADR-014](../001-terraform-ci-pipeline/decisions/ADR-014-azure-resource-naming.md).

## Non-goals

- Changing Azure service-mandated resource or subnet names.

## User stories

- As an operator, I want resource names to identify their environment so that deployed resources can be distinguished across environments.

## Requirements

- Use `d` for development, `t` for testing, and `p` for production.
- Use `<resource-abbreviation>-terraform-training-<environment-code>-eastus-<instance>`, with `001` as the initial instance identifier, wherever Azure rules permit.
- Select the environment through one `environment` input with values `development`, `testing`, or `production`, then derive the corresponding code.
- Include the selected environment code in resource names wherever Azure naming rules permit.
- Derive the code from one selected environment configuration; do not scatter inconsistent literals across resource declarations.
- Under ADR-018, retain `pip-server-terraform-training-<environment-code>-eastus-001` for the server public IP, avoiding the retired Bastion IP name. No JIT policy or Bastion subnet is created.

## Acceptance criteria

- [ ] Selecting development derives the code `d`; testing derives `t`; production derives `p`.
- [ ] The `environment` input accepts only `development`, `testing`, or `production`; other values are rejected.
- [ ] Terraform resource names include the selected code wherever permitted by Azure naming rules.
- [ ] Service-mandated names remain unchanged and valid.
- [ ] Resource names use the specified component order and conform to Azure-specific character, length, and uniqueness rules.

## Constraints and assumptions

- The environment code mapping is accepted in [ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md).
- The component order is accepted in [ADR-014](../001-terraform-ci-pipeline/decisions/ADR-014-azure-resource-naming.md).
- This naming feature is consumed by the network, server VM and public-access features.

## Open questions

None. The resource naming pattern and environment selector are decided in ADR-009 and ADR-014.