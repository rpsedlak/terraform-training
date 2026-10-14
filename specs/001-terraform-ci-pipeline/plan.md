# Plan: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Status:** Draft  
**Last updated:** 2026-10-14

## Technical approach

Keep the pipeline definition separate from Terraform configuration. Run formatting and validation on proposed changes, then generate a reviewable plan. Place apply behind the selected platform's protected approval mechanism. Do not implement the pipeline until the open platform, provider, version, backend, and identity decisions in the spec are resolved.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| CI platform | Unresolved | Determines pipeline syntax and approval controls. |
| Terraform version | Unresolved | Must be pinned consistently in local and CI workflows. |
| Cloud provider and root module | Unresolved | Determines provider configuration and validation prerequisites. |
| State backend and locking | Unresolved | State must be shared and protected for team workflows. |
| Execution identity | Unresolved | Must support least privilege and avoid long-lived repository secrets. |

## Security and operations

- Credentials and permissions: use the selected CI platform's secure identity mechanism; never commit credentials.
- State and locking: select a remote backend with locking before enabling shared applies.
- Deployment approvals and rollback: require a protected, explicit approval before apply; define recovery expectations with the provider choice.
- Cost and cleanup: no real infrastructure is created until the example's provider, budget expectations, and cleanup path are documented.

## Validation

- Run the chosen Terraform formatter in check mode and verify it rejects an intentionally unformatted fixture.
- Run `terraform validate` against the configured root module and verify invalid configuration fails.
- Inspect the proposed-change workflow to confirm plan review precedes any apply job.
- Confirm repository and CI configuration do not expose secrets or publish sensitive plan data to untrusted users.

## Risks

- Publishing plan output can expose sensitive values; restrict access and retention, or use a sanitized review method.
- Untrusted pull-request code can attempt to exfiltrate credentials; do not expose deployment credentials to untrusted jobs.
- A local-only state workflow does not support safe concurrent team applies; choose remote state and locking before enabling apply.