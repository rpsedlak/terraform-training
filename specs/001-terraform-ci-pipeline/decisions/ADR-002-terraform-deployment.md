# ADR-002: Provision the Environment Using Terraform

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The training project needs a consistent, reviewable way to define and provision its Azure environment.

## Decision

The environment will be deployed using Terraform. Terraform configuration will define the infrastructure, and Terraform plans will be reviewed before approved applies.

## Consequences

- Infrastructure changes will be represented and reviewed as Terraform configuration.
- Terraform version, module structure, Azure resource scope, state backend, and execution identity remain separate decisions and must be resolved before implementation.
- Terraform state and any sensitive plan output must be protected and must not be committed to the repository.