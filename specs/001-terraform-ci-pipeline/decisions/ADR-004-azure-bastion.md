# ADR-004: Deploy Azure Bastion

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The environment's network design includes an `AzureBastionSubnet` in the single virtual network, as recorded in [ADR-003](ADR-003-azure-network-topology.md). The environment needs a decision on whether to deploy the Azure Bastion service into that network.

## Decision

Deploy Azure Bastion in the environment and place it in the `AzureBastionSubnet` defined by ADR-003.

## Consequences

- Terraform configuration will include the Azure Bastion resource and associate it with the designated `AzureBastionSubnet`.
- The Bastion SKU, public IP configuration, and subnet CIDR allocation remain to be selected and must meet current Azure requirements.
- Bastion-related costs and access controls must be considered before deployment.