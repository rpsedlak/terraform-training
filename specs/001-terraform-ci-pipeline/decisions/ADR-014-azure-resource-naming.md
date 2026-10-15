# ADR-014: Follow Azure Cloud Adoption Framework Naming

**Status:** Accepted  
**Date:** 2026-10-14

## Context

ADR-009 sets the required one-letter environment codes but leaves their placement and the rest of the resource naming pattern open.

## Decision

Use the Azure Cloud Adoption Framework naming components in this order where resource rules permit:

`<resource-abbreviation>-terraform-training-<environment-code>-eastus-<instance>`

Use `001` as the initial instance identifier. Map the environment selector to `d`, `t`, or `p` as specified in ADR-009. Preserve required Azure names and adapt or omit components where a resource has stricter character or length rules.

Examples include `rg-terraform-training-d-eastus-001` and `vm-terraform-training-d-eastus-001`. The servers subnet name follows the same component order; `AzureBastionSubnet` remains unchanged.

## Consequences

- Terraform derives the environment code and names from shared inputs rather than duplicated literals.
- Resource-specific naming exceptions, including global uniqueness and character restrictions, must be validated before deployment.

## References

- [Microsoft Cloud Adoption Framework resource naming guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)