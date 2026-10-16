# terraform-training

Learn how to build Terraform pipelines through a file-first, spec-driven workflow.

## Workflow

Project files are the source of truth. Every change starts with a specification and its implementation plan; code and pipeline configuration follow only after those files are reviewed.

1. Create a numbered feature directory under `specs/` using the templates in `specs/templates/`.
2. Write and review `spec.md`. Record user-visible behavior, acceptance criteria, constraints, and unresolved decisions. Do not hide assumptions in implementation code.
3. Write `plan.md` with the technical approach, validation strategy, and any infrastructure or security impact. Resolve decisions that block implementation.
4. Break the approved plan into small, verifiable items in `tasks.md`.
5. Implement tasks in order. Keep the spec, plan, and task statuses current as decisions or scope change.
6. Run the checks required by the acceptance criteria and record the outcome before marking the work complete.

Specs move through `Draft`, `Approved`, `In Progress`, and `Complete`. An approved spec is required before implementation; changes to scope or acceptance criteria are made in the spec first.

## Project Structure

```text
.github/
	copilot-instructions.md
	workflows/
		terraform-ci.yml
		terraform-deploy.yml
infra/
	Terraform root module
specs/
	README.md
	templates/
		spec.md
		plan.md
		tasks.md
	001-terraform-ci-pipeline/
		spec.md
		plan.md
		tasks.md
	002-azure-environment/
		spec.md
		plan.md
		tasks.md
	003-network-foundation/
		spec.md
		plan.md
		tasks.md
	004-azure-bastion/
		spec.md
		plan.md
		tasks.md
	005-server-vm/
		spec.md
		plan.md
		tasks.md
	006-environment-naming/
		spec.md
		plan.md
		tasks.md
	007-jit-vm-access/
		spec.md
		plan.md
		tasks.md
```

The Azure environment integrates network, server VM, naming, and source-restricted public access features. [Feature 007](specs/007-jit-vm-access/spec.md) replaces Bastion under [ADR-018](specs/001-terraform-ci-pipeline/decisions/ADR-018-source-restricted-rdp.md). RDP is allowed only from `69.244.159.36/32`; no JIT service or paid Defender plan is required. Real deployment still requires explicit authorization.

## Terraform Checks

The root module is in `infra/`. Terraform 1.16.6 is required. These checks do not contact Azure or create resources:

```sh
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra init -backend=false -input=false -lockfile=readonly
terraform -chdir=infra validate
terraform -chdir=infra test
ruby tests/workflows_test.rb
ruby tests/terraform_source_test.rb
```

For a local plan, authenticate with Azure CLI and retrieve the VM username and password from Key Vault secrets `adminuser` and `adminpassword`. Supply them through Terraform input variables without printing or saving their values. Do not run `terraform apply` without explicit authorization.

Development, testing and production all default to `Standard_D2ds_v6` under [ADR-019](specs/001-terraform-ci-pipeline/decisions/ADR-019-shared-d2ds-v6-vm-size.md). Terraform, manual workflow dispatch and pull-request plans use the same default. B-series overrides with at least two vCPUs remain supported; other non-B-series sizes are rejected. Verify Ddsv6-family and regional quota before deployment. No deployment is performed by changing these defaults; the production GitHub environment-name mismatch remains a separate prerequisite.

## Direct RDP Access

The server has a Standard static IPv4 public IP. Terraform owns two inbound NSG rules: allow TCP 3389 from `69.244.159.36/32` at priority 100, then deny TCP 3389 from every other source at priority 110. The explicit deny also blocks RDP from private-network sources that Azure's default virtual-network rule would otherwise allow. No additional management ports or UDP RDP are opened.

Connect with an RDP client from the public egress address `69.244.159.36`, using the existing administrator credentials from Key Vault. Read the destination from `terraform -chdir=infra output -raw server_public_ip_address`; `69.244.159.36` is the client source address, not the server destination. CI review summaries intentionally omit output values. Never expose credentials or download unrestricted state to retrieve connection details.

No JIT request, time limit, Defender Plan 2, security-pricing read permissions, or AzAPI provider is required. Existing security-service billing is neither enabled nor disabled by this configuration. Access is continuously available to authenticated clients using the approved egress IP. If your ISP, VPN or router changes that IP, access will fail until a reviewed specification/Terraform change updates the allowlist; never widen it to `*` to troubleshoot.

Provider registration is explicit setup: `Microsoft.Network` and `Microsoft.Compute` must already be registered. AzureRM automatic registration remains disabled. Existing `ARM_*` OIDC settings, least-privilege compute/network/state permissions, and Key Vault secret-read permissions remain unchanged; no JIT-specific operator role is needed.

## Existing Bastion Migration

This section describes future operations, not an authorized deployment. Review the correct environment's remote state and live resources, not an untracked local state file.

1. Confirm the existing servers-subnet NSG association is intact. The NIC's public-IP attachment depends on that association, so the source restriction is installed before public access is attached.
2. Review the plan: remove the Bastion host, its public IP and subnet; create or retain the distinctly named server public IP; update the NSG to the exact trusted-IP allow and all-other-RDP deny; update the NIC in place. Existing Bastion inline rules are replaced by Terraform, without a manual rule-clearing or licensing prerequisite. Preserve VM/NIC/VNet/servers-subnet identities and CIDRs. Do not apply without explicit authorization through the protected workflow.
3. The earlier JIT implementation was code-only. If JIT was separately deployed, first obtain separate authorization for a transition that retains AzAPI long enough to destroy its policy and reconcile its state. Verify no external policy recreates Defender rules before switching to Terraform-owned inline rules. Do not remove state entries to abandon a live policy or change Defender billing.
4. After an authorized deployment, confirm new RDP connections succeed from `69.244.159.36` and fail from another public IP and private-network sources. Review the effective NSG rules and a subsequent Terraform plan for unexpected changes.

If access fails, retain the source restriction and NSG association. A separately reviewed rollback may detach the public IP. Never add unrestricted RDP or silently restore paid Bastion services.

## Azure and GitHub Setup

The Azure Blob state resource group and container must exist before remote `terraform init`; this repository does not bootstrap them. The state storage account is `dizzyterraform20261014` and the container is `tfstate`. State keys are `tftraining-development.tfstate`, `tftraining-testing.tfstate`, and `tftraining-production.tfstate`. GitHub Actions reads the resource group name from `TF_STATE_RESOURCE_GROUP`.

Configure GitHub environments `terraform-plan-development`, `terraform-plan-testing`, `terraform-plan-production`, and `terraform-apply-development`, `terraform-apply-testing`, `terraform-apply-production`. Require reviewers for each environment. Under [ADR-020](specs/001-terraform-ci-pipeline/decisions/ADR-020-development-deployment-branch.md), manually deploy development from `development-20261015`; testing and production remain main-only. Existing development `development-*` allowlists already permit the selected branch; retain reviewer gates and other protections. Configure federated Microsoft Entra identities with least-privilege plan and apply permissions, including Key Vault secret-read access to `adminuser` and `adminpassword`. Set environment variables `AZURE_PLAN_CLIENT_ID`, `AZURE_APPLY_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and `AZURE_KEY_VAULT_NAME`. VM credential values are not stored in GitHub secrets or variables. Set repository variable `TF_ENVIRONMENT` to choose the development/test/production environment used by pull-request plans.

Pull requests run formatting and validation without Azure credentials. Same-repository plan runs use a protected plan environment and publish resource addresses, actions, and changed attribute names, never attribute values. Manually dispatch the workflow from `development-20261015` for development, or from `main` for testing/production. Plan and apply reject mismatched environment/branch combinations. Apply re-plans after the protected reviewer gate and stops if the sanitized summary differs from the reviewed plan.