# Tasks: Azure Environment

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Approve features 003 through 006 and resolve their implementation-blocking questions.
- [ ] Select the Terraform version, remote state backend/locking, and deployment identity.
- [ ] Decide the Terraform root-module and component integration structure.

## Implementation

- [ ] Add the Terraform root module and Azure provider configuration after the specification is approved.
- [ ] Integrate the approved network, Bastion, server VM, and naming features into the Terraform environment.
- [ ] Configure the selected Terraform version, provider, backend, and deployment identity.
- [ ] Integrate the environment with the protected CI workflow specified in feature 001.

## Verification

- [x] Trace ADR-001 through ADR-009 into the environment requirements and plan.
- [x] Verify local Markdown links resolve and `git diff --check` passes for the specification changes.
- [ ] Run `terraform fmt -check` and `terraform validate` with the selected Terraform version.
- [ ] Verify the plan contains one `/22` VNet and the required subnet layout, including the `/24` servers subnet.
- [ ] Verify the Standard SKU gateway and Azure Bastion are associated with their designated subnets.
- [ ] Verify exactly one VM is in the servers subnet and no public IP is attached to its NIC.
- [ ] Verify `Standard_B2s_v2` is the default and invalid overrides are rejected.
- [ ] Verify the VM's attached disk uses the selected Premium managed SKU.
- [ ] Verify resource names use the selected environment code where permitted and preserve service-mandated names.
- [ ] Review the plan against every acceptance criterion; do not apply without explicit authorization.
- [ ] Record check results and evidence in this task file.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>