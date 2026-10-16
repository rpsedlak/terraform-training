# ADR-019: Use Standard_D2ds_v6 Across All Environments

**Status:** Accepted
**Date:** 2026-10-15

## Context

Development uses `Standard_D2ds_v6` under ADR-016 because the East US Bsv2 quota is zero. The user requested that testing and production match development rather than use the B-series default.

## Decision

Use `Standard_D2ds_v6` as the default server VM size for development, testing and production. Align the Terraform input default, manual workflow dispatch default and pull-request plan fallback. Accept this SKU in every approved environment, removing ADR-016's development-only restriction.

Retain the existing input API and B-series overrides with at least two vCPUs. Other non-B-series sizes remain rejected. Environment names, state isolation, network, image, credentials, disk and approval requirements are unchanged.

This supersedes ADR-006's `Standard_B2s_v2` default and ADR-016's environment restriction. This decision authorizes configuration changes only, not deployment, quota changes, GitHub environment renaming, commits or PR merges.

## Consequences

- All three environments use the same two-vCPU `Standard_D2ds_v6` by default; explicit supported B-series overrides remain possible.
- Verify regional and Ddsv6-family quota before each deployment. Matching a SKU does not guarantee capacity for simultaneous environments.
- Tests must cover default and explicit D2ds_v6 acceptance in all environments, valid B-series overrides and invalid/undersized SKU rejection.
- Production's previously identified protected-environment name mismatch remains a separate deployment blocker.