# ADR-012: Use GitHub Actions for Terraform CI

**Status:** Accepted; development deployment branch restriction superseded by [ADR-020](ADR-020-development-deployment-branch.md). The original decision below remains historical for that clause.
**Date:** 2026-10-14

## Context

The Terraform environment needs automated checks, reviewable plans, and a protected apply approval.

## Decision

Use GitHub Actions. Run formatting and validation for pull requests. Use GitHub deployment environments with required reviewers for privileged plan and apply jobs, and restrict apply to the protected `main` branch. Authenticate to Azure with GitHub OIDC and Microsoft Entra workload identity federation; do not store long-lived Azure credentials in GitHub secrets.

## Consequences

- Workflow jobs receive only the permissions they need; untrusted fork pull requests do not receive Azure identity tokens.
- OIDC trust conditions must restrict the repository, branch, workflow, and protected environment as appropriate.
- Plan output must be inspectable by authorized reviewers without exposing sensitive values in workflow logs.
- Apply remains gated by required reviewers and only runs from `main`.

## References

- [Configure OpenID Connect in Azure](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Manage GitHub Actions environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)