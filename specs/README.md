# Specifications

Each feature lives in its own numbered directory: `NNN-short-name/`. The spec is the authority for what and why; the plan records how; the task list tracks implementation and verification.

## Lifecycle

- `Draft`: requirements or decisions are still being shaped; implementation must not start.
- `Approved`: acceptance criteria and blocking decisions have been reviewed; implementation may start.
- `In Progress`: approved tasks are being implemented and verified.
- `Complete`: acceptance criteria passed and evidence is recorded in `tasks.md`.

Copy the three files from `templates/` when creating a feature. Keep all three in sync. If implementation reveals a mismatch, stop and update the spec and plan before continuing.

## Features

| Feature | Status | Purpose |
| --- | --- | --- |
| [001 Terraform CI Pipeline](001-terraform-ci-pipeline/spec.md) | Draft | Define a safe CI workflow for Terraform deployments to Azure. |