# ADR-009: Use Single-Letter Environment Naming Codes

**Status:** Accepted  
**Date:** 2026-10-14

## Context

Resources are built for multiple deployment environments. Their names need a concise, consistent way to identify the environment they belong to.

## Decision

Include a single-letter environment code in resource names, using this mapping:

| Environment | Code |
| --- | --- |
| Development | `d` |
| Testing | `t` |
| Production | `p` |

Apply the code wherever the Azure resource's naming rules permit. Keep service-mandated names unchanged.

## Consequences

- Resource names can be associated with their deployment environment using the assigned code.
- The position of the code, separators, and the rest of the resource naming pattern remain to be defined.
- Terraform should derive the code from the selected environment rather than duplicate inconsistent literal values across resource declarations.