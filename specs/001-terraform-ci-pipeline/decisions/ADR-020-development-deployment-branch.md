# ADR-020: Deploy Development From Its Development Branch

**Status:** Accepted
**Date:** 2026-10-16

## Decision

Manual development plan/apply jobs run only from `development-20261015`. Manual testing and production jobs remain restricted to `main`. All applies still require their protected GitHub environment approval, OIDC, environment-specific state and the approved VM-size validation.

This supersedes only the main-only development deployment clause of ADR-012. Do not expand development GitHub environment allowlists to include `main`: their existing `development-*` policies already permit the selected branch. Other environment policies, reviewer rules, identity trusts and roles remain unchanged.

## Consequences

- Plan and apply must use the same environment/branch predicate: development on `refs/heads/development-20261015`; testing or production on `refs/heads/main`.
- Reject development on main, testing/production on the development branch, unknown environments, and other refs. Preserve the existing same-repository PR-plan checks without adding an automatic apply trigger.
- The user explicitly authorized the scoped workflow/spec/test commit and push to `development-20261015`, followed by its protected development deployment. This does not authorize a merge into main or bypass of required approvals.
- Changing the named development branch later requires another reviewed policy/configuration change.