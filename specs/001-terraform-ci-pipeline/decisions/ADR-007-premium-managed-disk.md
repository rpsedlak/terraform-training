# ADR-007: Use a Premium Managed Disk

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The environment includes one VM in the servers subnet, as recorded in [ADR-005](ADR-005-single-server-vm.md). The storage tier for its attached disk must be defined.

## Decision

The VM's attached disk shall be an Azure Premium managed disk.

## Consequences

- Terraform configuration must create or configure the VM's attached disk using Premium managed storage.
- The exact disk SKU, performance settings, and whether this refers to the OS disk or a data disk remain to be specified before implementation.
- Disk capacity and regional availability must be checked against the selected SKU and VM size.