# Plan: Terraform Destroy Operations

**Related spec:** [spec.md](spec.md)  
**Status:** Proposed  
**Last updated:** 2026-11-25

## Technical Approach

Implement a dedicated, manual-only terraform destroy workflow with comprehensive safety mechanisms. The workflow prevents accidental destruction through:

1. **Manual trigger only** - Never automatic, always explicit workflow dispatch
2. **Environment confirmation** - User must type environment name to confirm intent
3. **Branch restrictions** - Development only from `development-20261015`; testing/production only from `main`
4. **Approval gates** - Separate GitHub protected environments with required reviewers per environment
5. **State backup** - Automatic pre-destruction backup of Terraform state
6. **Plan preview** - Shows all resources to be destroyed before approval
7. **Audit logging** - Full trail of who requested destruction and when

The workflow follows the same Azure OIDC authentication and state management as plan/apply jobs. Backups are stored as GitHub artifacts for 30 days, enabling recovery if destruction was unintended.

Branch restrictions follow ADR-020: development destruction from `development-20261015` only; testing/production destruction from `main` only. This prevents accidental destruction of production via incorrect branch selection.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Destroy trigger | Manual workflow_dispatch only | Prevents accidents from automatic triggers |
| Confirmation mechanism | User types environment name | Requires deliberate action to prevent typos |
| Branch controls | ADR-020 model (dev on development-20261015, prod on main) | Consistent with deployment model, prevents cross-environment mistakes |
| Approval | Separate protected environment per environment | Different reviewers for different environments |
| State backup | Automatic, pre-destruction | Enables recovery if destruction is unintended |
| Azure auth | Same OIDC as plan/apply | Reuses existing workload identity, same permissions scope |
| Audit trail | GitHub Actions logs + summaries | Full visibility into destruction requests and execution |

## Security and Operations

- **Access control**: Only authorized GitHub users with Actions access can trigger workflows
- **Input validation**: Environment name must match confirmation value (typo prevention)
- **Branch validation**: Environment/branch must match allowed combinations
- **Approval requirement**: Each environment has separate required reviewers
- **State protection**: Pre-destruction state backup allows rollback
- **Audit logging**: Full trail visible in GitHub Actions and Azure activity logs
- **OIDC scope**: Azure credentials scoped to subscription and authenticated with workload identity federation
- **Artifact retention**: State backups retained for 30 days per GitHub policy

## Validation

- Verify workflow_dispatch is the only trigger (no PR, push, or schedule triggers)
- Verify input validation works (typos are caught)
- Verify branch restrictions work (wrong branch prevents destruction)
- Verify approval gates block execution until review
- Verify state backup artifact is created and downloadable
- Verify destroy plan shows affected resources
- Verify audit trail appears in workflow logs and job summaries

## Risks

- **Data loss**: Destroy permanently removes all managed resources
- **Service disruption**: Production destruction removes active infrastructure
- **State loss**: If state backup fails, recovery is not possible
- **Approval bypass**: If access control is compromised, destructive operations can proceed without review
- **Incomplete destruction**: Manually created resources not managed by Terraform will not be destroyed

## Mitigations

- Require explicit confirmation (environment name input)
- Automatic state backup before destruction
- Protected environment approval gates per environment
- Clear warnings in plan and execution summaries
- 30-day artifact retention for recovery
- Separate approval chains for each environment
- Audit trail for compliance

## Recovery Procedures

If destruction is unintended:

1. Download state backup from workflow artifacts (30 days available)
2. Use `terraform state push [backup-file]` to restore
3. Apply infrastructure by pushing to appropriate branch or manual dispatch
4. Verify resources recreated in Azure portal

---

## Workflow Specification

### File
`.github/workflows/terraform-destroy.yml`

### Inputs
- `environment`: choice of development, testing, production
- `environment_confirmation`: user must type environment name exactly
- `backup_snapshot`: boolean (default true) to backup state before destroy

### Jobs

#### validate
Validates user inputs and branch restrictions before proceeding.

**Steps:**
1. Confirm environment name matches confirmation input (prevents typos)
2. Verify branch matches environment (dev on development-20261015, prod on main)

**Outputs:**
- `environment_safe`: true if validation passes

#### plan-destroy
Plans the destruction and shows affected resources.

**Environment:** `terraform-destroy-[environment]` (protected)

**Steps:**
1. Checkout code
2. Setup Terraform 1.16.6
3. Authenticate with Azure OIDC
4. Read VM credentials from Key Vault
5. Initialize remote state
6. Create state backup (if enabled)
7. Run `terraform plan -destroy`
8. Parse and summarize destruction plan
9. Publish destruction summary to job summary
10. Upload state backup artifact

**Outputs:**
- `destroy_summary`: JSON array of resources to destroy
- `resource_count`: Number of resources to destroy

#### destroy
Executes the destruction after approval.

**Environment:** `terraform-destroy-[environment]` (protected, requires approval)

**Steps:**
1. Checkout code
2. Setup Terraform 1.16.6
3. Authenticate with Azure OIDC
4. Read VM credentials from Key Vault
5. Initialize remote state
6. Run `terraform destroy -auto-approve`
7. Publish destruction report to job summary

---

## Related ADRs

- **ADR-012**: GitHub Actions deployment, OIDC, protected environments
- **ADR-020**: Development deployment from `development-20261015`; testing/production from `main`
- **ADR-013**: Terraform toolchain and remote state

## References

- [ADR-022: Terraform Destroy Strategy](decisions/ADR-022-terraform-destroy.md)
- [Terraform Destroy Guide](../../TERRAFORM_DESTROY_GUIDE.md)
- [Terraform destroy command](https://www.terraform.io/cli/commands/destroy)
- [GitHub Actions protected environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
