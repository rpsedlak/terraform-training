# ADR-021: Deploy Automatically After Merge, Behind Protected Approval

**Status:** Accepted
**Date:** 2026-11-25

## Decision

Pushes (merges) to approved branches start the plan and apply workflow automatically:

| Push to | Environments applied |
| --- | --- |
| `development-20261015` | `development` |
| `main` | `testing` and `production` |

Manual `workflow_dispatch` remains available with the ADR-020 environment/branch mapping. Every apply, automatic or manual, still runs in its protected `terraform-apply-<environment>` GitHub environment and requires that environment's reviewer approval. Apply re-plans and stops if the sanitized summary differs from the reviewed plan. Pull requests continue to run plan only, never apply.

This supersedes only the "no automatic apply trigger" statements in ADR-020 and the spec non-goal against automatic application. ADR-020's manual branch mapping, GitHub branch allowlists, reviewer rules, OIDC trusts, roles and state keys are unchanged.

## Consequences

- Automatic apply is limited to a push on `main` or `development-20261015`; any other ref or event does not apply. Changes reach those branches only through the repository's normal review and merge process, so no unreviewed change is applied automatically.
- The approval gate is the control against unintended deployment; it must not be bypassed or removed for automatic runs.
- Automatic and manual runs share the default VM size `Standard_D2ds_v6` under ADR-019 when no dispatch input exists.
- Each environment's plan summary must be generated for the environment being applied, so the apply comparison is meaningful. Production applying only after testing succeeds is an open implementation requirement tracked in `tasks.md`.
