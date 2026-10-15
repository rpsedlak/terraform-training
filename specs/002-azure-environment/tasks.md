# Tasks: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [x] Approve features 003 through 006 and resolve implementation-blocking decisions.
- [x] Select Terraform 1.16.6, Azure Blob state/OIDC, and the `infra/` root module (ADR-013).

## Implementation

- [ ] Add the Terraform root module and Azure provider configuration after the specification is approved.
- [ ] Integrate the approved network, Bastion, server VM, and naming features into the Terraform environment.
- [ ] Configure the pinned Terraform version, provider lock file, backend, and deployment identity.
- [ ] Integrate the environment with the protected CI workflow specified in feature 001.

## Verification

- [x] Trace ADR-001 through ADR-014 into the environment requirements and plan.
- [x] Verify local Markdown links resolve and `git diff --check` passes for the specification changes.
- [ ] Run `terraform fmt -check` and `terraform validate` with the selected Terraform version.
- [ ] Verify the plan contains one `/22` VNet and the required subnet layout, including the `/24` servers subnet.
- [ ] Verify no gateway is deployed and Basic Bastion is associated with `AzureBastionSubnet`.
- [ ] Verify exactly one VM is in the servers subnet and no public IP is attached to its NIC.
- [ ] Verify `Standard_B2s_v2` is the default and invalid overrides are rejected.
- [ ] Verify the VM's attached disk uses the selected Premium managed SKU.
- [ ] Verify resource names use the selected environment code where permitted and preserve service-mandated names.
- [ ] Review the plan against every acceptance criterion; do not apply without explicit authorization.
- [ ] Record check results and evidence in this task file.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>