# ADR-004: Deploy Azure Bastion

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The environment's network design includes an `AzureBastionSubnet` in the single virtual network, as recorded in [ADR-003](ADR-003-azure-network-topology.md). The environment needs a decision on whether to deploy the Azure Bastion service into that network.

## Decision

Deploy Azure Bastion in the environment and place it in the `AzureBastionSubnet` defined by ADR-003.

## Consequences

- Terraform configuration will include the Azure Bastion resource and associate it with the designated `AzureBastionSubnet`.
- Use the Basic SKU in East US. Microsoft lists Developer as unavailable in East US; Basic is the lowest-cost dedicated SKU available there.
- Use a Standard SKU, static IPv4 public IP. The server VM itself remains without a public IP under ADR-008.
- `AzureBastionSubnet` uses `10.20.0.0/26`, meeting the dedicated Bastion subnet minimum.
- Bastion-related costs and access controls must be considered before deployment.

## References

- [Azure Bastion SKU comparison](https://learn.microsoft.com/en-us/azure/bastion/bastion-sku-comparison)
- [Azure Bastion configuration settings](https://learn.microsoft.com/en-us/azure/bastion/configuration-settings)