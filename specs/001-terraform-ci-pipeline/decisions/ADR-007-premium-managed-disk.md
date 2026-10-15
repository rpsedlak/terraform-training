# ADR-007: Use a Premium Managed Disk

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The environment includes one VM in the servers subnet, as recorded in [ADR-005](ADR-005-single-server-vm.md). The storage tier for its attached disk must be defined.

## Decision

Use an Azure Premium SSD P10 managed disk for the VM's operating system disk. Do not create a separate data disk.

## Consequences

- Terraform configuration must create or configure the VM's OS disk as Premium SSD P10 (128 GiB).
- No additional data disk is in scope.
- Confirm regional availability and compatibility with the selected VM size before deployment.