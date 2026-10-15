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
| [001 Terraform CI Pipeline](001-terraform-ci-pipeline/spec.md) | Draft | Define a safe CI workflow for the approved Azure environment. |
| [002 Azure Environment](002-azure-environment/spec.md) | Draft | Integrate the component specifications and shared deployment decisions. |
| [003 Network Foundation](003-network-foundation/spec.md) | Draft | Specify the VNet, gateway, and subnet topology from ADR-003. |
| [004 Azure Bastion](004-azure-bastion/spec.md) | Draft | Specify Azure Bastion deployment from ADR-004. |
| [005 Server VM](005-server-vm/spec.md) | Draft | Specify the server VM, size, disk, and public IP constraints from ADR-005 through ADR-008. |
| [006 Environment Naming](006-environment-naming/spec.md) | Draft | Specify the environment codes from ADR-009. |