# ADR-011: Deploy the Environment in East US

**Status:** Accepted  
**Date:** 2026-10-14

## Context

Azure resource availability and cost depend on deployment region. A region is required for a coherent environment plan.

## Decision

Deploy the Azure environment in East US (`eastus`).

## Consequences

- Terraform resources use the `eastus` Azure location unless a resource type has a documented regional constraint.
- VM, disk, Bastion, and provider resource availability must be verified for East US before deployment.
- Resource names use the region component `eastus` where the naming convention permits.