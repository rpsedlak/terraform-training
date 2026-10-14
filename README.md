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
```

The Azure environment requirements are specified in `specs/002-azure-environment/` and traced to accepted decision records. Infrastructure and pipeline implementation remain out of scope until their specifications are approved.