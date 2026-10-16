# ADR-016: Use Standard_D2ds_v6 for Development VM

**Status:** Superseded by [ADR-019](ADR-019-shared-d2ds-v6-vm-size.md), which defaults all environments to D2ds_v6. Text below records the original development-only exception.
**Date:** 2026-10-14

## Context

The development deployment using the default `Standard_B2s_v2` failed because the Azure subscription's East US `standardBsv2Family` quota is zero. The East US `standardDdsv6Family` has quota available, and `Standard_D2ds_v6` is available in the region with two vCPUs.

## Decision

Use `Standard_D2ds_v6` as the VM size for the development deployment to fit the available quota. Keep `Standard_B2s_v2` as the default for other environments and retain the B-series override rule, except for this development-only override.

## Consequences

- The Terraform VM-size validation and development workflow input must allow `Standard_D2ds_v6` only when `environment` is `development`.
- Testing and production remain on the B-series default or another valid B-series override.
- Re-run plan review before applying the development override. This decision does not authorize another apply by itself.