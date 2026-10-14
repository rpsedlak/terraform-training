# Tasks: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Decide and approve the CI platform and protected approval mechanism.
- [ ] Decide and approve the Terraform version and Azure resource/root module scope.
- [ ] Choose the gateway type and allocate non-overlapping CIDR ranges for the VNet, GatewaySubnet, and AzureBastionSubnet; verify subnet sizes against Azure requirements.
- [ ] Decide and approve the state backend, locking, and execution identity.
- [ ] Define safe plan review, artifact access, and retention expectations.

## Implementation

- [ ] Add the minimal Terraform root module and ignore rules required by the approved scope.
- [ ] Implement the single-VNet and subnet topology defined in ADR-003.
- [ ] Deploy Azure Bastion into `AzureBastionSubnet` as defined in ADR-004.
- [ ] Add CI checks for formatting and Terraform validation.
- [ ] Add plan generation and review behavior for proposed changes.
- [ ] Add an explicitly approved apply path using the selected secure identity mechanism.

## Verification

- [ ] Demonstrate formatting check failure for a formatting violation.
- [ ] Demonstrate validation failure for invalid Terraform configuration.
- [ ] Verify the Terraform plan deploys Azure Bastion into `AzureBastionSubnet`.
- [ ] Verify the proposed-change flow exposes a reviewable plan before apply.
- [ ] Verify apply is blocked until the protected approval is granted.
- [ ] Confirm secrets, state, and sensitive plan output are not committed or exposed to untrusted jobs.
- [ ] Confirm all acceptance criteria in `spec.md` and record evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>