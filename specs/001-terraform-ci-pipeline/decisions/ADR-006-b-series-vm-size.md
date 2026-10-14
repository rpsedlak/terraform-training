# ADR-006: Use a B-Series VM with at Least Two Cores

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The environment will include one VM in the servers subnet as recorded in [ADR-005](ADR-005-single-server-vm.md). A minimum VM size family and core count are needed for the deployment specification.

## Decision

Use `Standard_B2s_v2` as the VM size by default. Expose the VM size as a Terraform input variable so deployments can override the default. The configured SKU, including any override, must be a B-series size with at least two cores (vCPUs).

## Consequences

- Deployments that do not set the input variable use `Standard_B2s_v2`.
- An override may select another B-series SKU, but it must provide at least two vCPUs and be available in the target Azure region.
- The Terraform variable name remains an implementation detail.
- Terraform validation or plan review must verify the default and any configured override satisfy the family and core-count requirements.