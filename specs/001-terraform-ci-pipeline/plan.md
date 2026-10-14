# Plan: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Status:** Draft  
**Last updated:** 2026-10-14

## Technical approach

Keep pipeline configuration separate from infrastructure configuration. Run formatting and validation against the root module defined in [002 Azure Environment](../002-azure-environment/spec.md), generate a reviewable plan for proposed changes, and place apply behind the selected CI platform's protected approval mechanism. Do not expose deployment credentials or sensitive plan output to untrusted changes.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| CI platform | Unresolved | Determines pipeline syntax, triggers, and approval controls. |
| Protected apply approval | Unresolved | Must prevent apply from running on unreviewed changes. |
| Plan output handling | Unresolved | Determines secure reviewer access and retention. |
| Deployment identity | Unresolved | Must use least privilege and avoid long-lived repository secrets. |
| Environment configuration | Follow [002 Azure Environment](../002-azure-environment/plan.md) | Keeps the pipeline aligned with the independently specified infrastructure. |

## Security and operations

- Credentials and permissions: use the selected CI platform's secure identity mechanism; never commit credentials.
- Credentials and permissions: expose credentials only to trusted apply jobs and use the selected platform's secure identity mechanism.
- Plan artifacts: restrict access and retention because Terraform plans may contain sensitive values.
- Apply: require a protected, explicit approval before any apply job runs.

## Validation

- Verify formatting and validation checks execute against the root module in feature 002.
- Verify a proposed change generates a reviewable plan without applying it.
- Verify untrusted changes cannot access credentials or sensitive plan output.
- Verify apply remains blocked until the protected approval is granted.

## Risks

- Publishing plan output can expose sensitive values; restrict access and retention, or use a sanitized review method.
- Untrusted pull-request code can attempt to exfiltrate credentials; do not expose deployment credentials to untrusted jobs.