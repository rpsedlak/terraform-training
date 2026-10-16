# Plan: Terraform CI Pipeline

**Related spec:** [spec.md](spec.md)  
**Status:** Approved
**Last updated:** 2026-10-14

## Technical approach

Keep pipeline configuration separate from infrastructure configuration. GitHub Actions runs formatting and validation on pull requests, while privileged plan and apply jobs use GitHub protected environments and Azure OIDC. Fork pull requests receive no Azure credentials. Manual dispatch passes the selected environment and VM size to both plan and apply. Under ADR-019, `Standard_D2ds_v6` is the shared default for development, testing and production; the manual input default and PR-plan fallback match Terraform, with existing valid B-series overrides retained. Reviewers inspect a sanitized plan summary before approving apply from `main`.

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
- Production OIDC setup: the user approved additive production trusts on the plan/apply applications already configured in the production GitHub environments. Preserve existing development records, issuer `https://token.actions.githubusercontent.com`, audience `api://AzureADTokenExchange`, and RBAC. Use the observed immutable-ID subjects `repo:rpsedlak@2582442/terraform-training@1419924521:environment:terraform-plan-production` and `repo:rpsedlak@2582442/terraform-training@1419924521:environment:terraform-apply-production`; do not substitute the older plain repository-name subject format. Verify both records before retrying. Sharing identities across environments is explicitly accepted for this deployment; no secrets or role expansion are created.
- Plan output: publish only a sanitized summary; do not print raw plan values in workflow logs.
- Apply: require approval from designated reviewers in the protected environment and restrict deployment branches to `main`.

## Validation

- Verify pull-request formatting and validation target `infra/`.
- Verify privileged plan output is sanitized and reviewable before apply.
- Verify fork pull requests cannot obtain Azure OIDC tokens.
- Verify apply requires `main` and protected-environment approval.

## Risks

- Publishing plan output can expose sensitive values; restrict access and retention, or use a sanitized review method.
- Untrusted pull-request code can attempt to exfiltrate credentials; do not expose deployment credentials to untrusted jobs.