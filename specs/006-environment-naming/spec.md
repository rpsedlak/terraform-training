# Feature: Environment Naming

**Status:** Draft  
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

Resources are deployed into development, testing, and production environments. Their names need a consistent environment identifier without violating Azure naming constraints.

## Goals

- Use the one-letter codes accepted in [ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md).
- Derive the code from the selected environment consistently across Terraform resources.

## Non-goals

- Defining all resource-name components, separators, or code position before a naming pattern is approved.
- Changing Azure service-mandated resource or subnet names.

## User stories

- As an operator, I want resource names to identify their environment so that deployed resources can be distinguished across environments.

## Requirements

- Use `d` for development, `t` for testing, and `p` for production.
- Include the selected environment code in resource names wherever Azure naming rules permit.
- Derive the code from one selected environment configuration; do not scatter inconsistent literals across resource declarations.
- Preserve service-mandated names such as `GatewaySubnet` and `AzureBastionSubnet`.

## Acceptance criteria

- [ ] Selecting development derives the code `d`; testing derives `t`; production derives `p`.
- [ ] Terraform resource names include the selected code wherever permitted by Azure naming rules.
- [ ] Service-mandated names remain unchanged and valid.
- [ ] Invalid environment selections are rejected.

## Constraints and assumptions

- The environment code mapping is accepted in [ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md).
- This naming feature is consumed by the network, Bastion, and server VM features.

## Open questions

- [ ] What is the complete resource naming pattern, including code position and separators?
- [ ] Which resource types have Azure-specific naming constraints that need exceptions?
- [ ] What parameter should select the environment in local and CI workflows?