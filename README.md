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
```

The Azure environment is specified by separate network, Bastion, server VM, and naming features, with `specs/002-azure-environment/` tracking their integration. All feature specifications are approved; implementation must follow their tasks, and no real deployment may run without explicit authorization.

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

For a development deployment, select `development` and `Standard_D2ds_v6` in the protected manual workflow dispatch to use the approved East US Bsv2-quota exception. The Terraform default remains `Standard_B2s_v2`; other overrides must satisfy the VM-size validation in the approved server VM spec.

## Azure and GitHub Setup

The Azure Blob state resource group and container must exist before remote `terraform init`; this repository does not bootstrap them. The state storage account is `dizzyterraform20261014` and the container is `tfstate`. State keys are `tftraining-development.tfstate`, `tftraining-testing.tfstate`, and `tftraining-production.tfstate`. GitHub Actions reads the resource group name from `TF_STATE_RESOURCE_GROUP`.

Configure GitHub environments `terraform-plan-development`, `terraform-plan-testing`, `terraform-plan-production`, and `terraform-apply-development`, `terraform-apply-testing`, `terraform-apply-production`. Require reviewers for each environment; restrict apply environments to `main`. Configure federated Microsoft Entra identities with least-privilege plan and apply permissions, including Key Vault secret-read access to `adminuser` and `adminpassword`. Set environment variables `AZURE_PLAN_CLIENT_ID`, `AZURE_APPLY_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and `AZURE_KEY_VAULT_NAME`. VM credential values are not stored in GitHub secrets or variables. Set repository variable `TF_ENVIRONMENT` to choose the development/test/production environment used by pull-request plans.

Pull requests run formatting and validation without Azure credentials. Same-repository plan runs use a protected plan environment and publish resource addresses, actions, and changed attribute names, never attribute values. Apply is manually dispatched from `main`, re-plans after the protected reviewer gate, and stops if the sanitized summary differs from the reviewed plan.