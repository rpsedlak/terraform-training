# Project Instructions

- Treat the files under `specs/` as the source of truth for requirements and scope.
- Before implementation, read the relevant approved `spec.md`, `plan.md`, and `tasks.md`.
- If requirements, acceptance criteria, or scope change, update the spec and plan before changing implementation.
- Do not make infrastructure deployment, credential, or provider assumptions that are absent from the approved files. Ask for a decision or record it as an open question.
- Never run `terraform apply` or trigger a real deployment unless the user explicitly requests it.
- Validate changes against the acceptance criteria and record the checks in the feature's task file.