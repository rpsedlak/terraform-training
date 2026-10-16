# Plan: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-16

## Technical approach

Keep pipeline configuration separate from infrastructure configuration. GitHub Actions runs formatting and validation on pull requests, while privileged plan and apply jobs use GitHub protected environments and Azure OIDC. Fork pull requests receive no Azure credentials. Manual dispatch passes the selected environment and VM size to both plan and apply. Under ADR-019, `Standard_D2ds_v6` is the shared default for development, testing and production; the manual input default and PR-plan fallback match Terraform, with existing valid B-series overrides retained. Under ADR-020, manual development jobs require `development-20261015`, while testing and production require `main`. Reviewers inspect a sanitized plan summary before approving apply on the environment's approved branch.

Use identical explicit manual-dispatch predicates in plan and apply: development plus its exact branch, or testing/production plus main. Preserve the existing PR-plan predicate. Test the entire normalized guard expressions to catch extra bypass clauses and wrong environment/ref combinations. Keep environment names, reviewer gates, state keys, OIDC, source-restricted RDP and VM sizing unchanged. Publish only the scoped branch correction to `development-20261015`; do not merge it into main as part of the authorized deployment.

The deployment jobs run on the approved self-hosted Windows runner. Explicitly select `shell: bash` for every Bash script, including both remote-state initialization steps; do not let POSIX assignments and line continuations execute under default PowerShell. Keep the backend keys, OIDC settings, runner labels and protected environments unchanged. A regression assertion in the existing workflow tests checks both initialization shells before a development retry. This compatibility fix does not authorize a commit, PR merge or approval bypass.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| CI platform and approval | GitHub Actions with required reviewers on a protected environment ([ADR-012](decisions/ADR-012-github-actions-deployment.md)) | Provides the selected workflow and explicit apply gate. |
| Azure authentication | OIDC and Microsoft Entra workload identity federation ([ADR-012](decisions/ADR-012-github-actions-deployment.md)) | Avoids long-lived credentials in repository secrets. |
| Terraform and state | Pinned CLI and Azure Blob backend ([ADR-013](decisions/ADR-013-terraform-toolchain-and-state.md)) | Reproducible CLI and remote locked state. |
| Environment configuration | Follow [002 Azure Environment](../002-azure-environment/plan.md) | Keeps the pipeline aligned with the approved infrastructure. |

## Security and operations

- Credentials and permissions: expose credentials only to trusted apply jobs and use the selected platform's secure identity mechanism.
- Plan output: publish only a sanitized summary; do not print raw plan values in workflow logs.
- Apply: require protected reviewers and the ADR-020 environment/branch mapping; preserve existing GitHub branch policies.

## Validation

- Verify pull-request formatting and validation target `infra/`.
- Verify privileged plan output is sanitized and reviewable before apply.
- Verify fork pull requests cannot obtain Azure OIDC tokens.
- Verify manual plan/apply predicates match: development on its exact development branch, testing/production on main, with required protected approval retained.

## Risks

- Publishing plan output can expose sensitive values; restrict access and retention, or use a sanitized review method.
- Untrusted pull-request code can attempt to exfiltrate credentials; do not expose deployment credentials to untrusted jobs.