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
| [001 Terraform CI Pipeline](001-terraform-ci-pipeline/spec.md) | Approved | Define the GitHub Actions CI workflow and protected Azure apply. |
| [002 Azure Environment](002-azure-environment/spec.md) | Approved | Integrate the component specifications and shared deployment decisions. |
| [003 Network Foundation](003-network-foundation/spec.md) | Approved | Specify the VNet and subnet topology from ADR-003 and ADR-010. |
| [004 Azure Bastion](004-azure-bastion/spec.md) | Superseded | Historical requirements replaced by feature 007 and ADR-017. |
| [005 Server VM](005-server-vm/spec.md) | Approved | Specify the server VM, size, disk and source-restricted public access under ADR-018. |
| [006 Environment Naming](006-environment-naming/spec.md) | Approved | Specify the environment codes and Azure naming format from ADR-009 and ADR-014. |
| [007 Public VM Access](007-jit-vm-access/spec.md) | In Progress | Direct public-IP RDP restricted to `69.244.159.36/32`; ADR-018 removes JIT and licensing prerequisites. |