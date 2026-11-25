# ADR-022: Terraform Destroy Strategy and Workflow

**Status:** Proposed  
**Date:** 2026-11-25

## Context

Infrastructure environments occasionally require complete teardown for cost management, testing reset, or decommissioning. Terraform destroy is a destructive operation that permanently removes all managed resources. Without proper safeguards, accidental execution could cause data loss and service outages.

The organization needs a controlled, auditable process for destruction that:
- Requires explicit, intentional action
- Provides separate controls per environment
- Prevents accidental destruction
- Is only available to authorized personnel
- Maintains audit trails
- Follows the existing deployment branch model (ADR-020)

## Decision

Implement a dedicated `terraform-destroy.yml` workflow with the following principles:

1. **Manual-only trigger**: Destroy only runs on explicit `workflow_dispatch` (never automatic)
2. **Environment-specific control**: Separate approval gates per environment
3. **Branch restrictions**: Follow ADR-020 model
   - Development destroy only from `development-20261015`
   - Testing/production destroy only from `main`
4. **Confirmation requirement**: Require explicit environment name input to confirm intent
5. **State backup**: Create Terraform state snapshot before destruction
6. **Audit logging**: Publish destruction plan to workflow summary for review
7. **Limited access**: Use GitHub protected environments with required reviewers
8. **Azure OIDC**: Use same federated identity approach as plan/apply jobs

## Consequences

**Positive:**
- Destroy operations are intentional and auditable
- Separate approval gates prevent cross-environment accidents
- State backups enable recovery if destruction is incorrect
- Clear audit trail of who destroyed what and when
- Protection against typos or unintended environment destruction

**Negative:**
- Requires explicit workflow dispatch (more steps than automated)
- Requires confirmation input (user must type environment name)
- Recovery requires manual state restoration
- Does not prevent destruction if approval is bypassed

## Assumptions

- Azure OIDC credentials have destroy permissions (same as apply)
- State backups are stored in the same remote backend
- Users understand terraform destroy semantics
- Required reviewers are properly configured in protected environments

## Related ADRs

- **ADR-012**: GitHub Actions deployment, OIDC, protected environments
- **ADR-020**: Development deployment from `development-20261015`; testing/production from `main`
- **ADR-013**: Terraform toolchain and remote state

## Implementation Details

### Trigger
- Workflow dispatch only: manual "Run workflow" button
- No automatic triggers (pull request, push, schedule)

### Inputs
- **environment**: choice of `development`, `testing`, or `production`
- **environment_confirmation**: user must type the full environment name to confirm
- **backup_snapshot**: optional flag to create state backup before destroy (default: true)

### Job Sequence
1. **Validate inputs**: Confirm environment name matches confirmation input
2. **Restrict branches**: 
   - If development: only from `development-20261015`
   - If testing/production: only from `main`
3. **Backup state**: Download current Terraform state as artifact
4. **Plan destroy**: Run `terraform plan -destroy` to show affected resources
5. **Publish plan**: Display destruction plan in GitHub job summary
6. **Require approval**: Use GitHub protected environment approval
7. **Execute destroy**: Run `terraform destroy` after approval
8. **Publish report**: Log destruction summary and timestamp

### Protected Environments

Three separate environments for destruction:
- `terraform-destroy-development`: approvers for dev destruction
- `terraform-destroy-testing`: approvers for test destruction  
- `terraform-destroy-production`: approvers for prod destruction

### State Backup

Before destruction, download and artifact the state file to enable recovery:
```bash
# Backup current state
terraform -chdir=infra state pull > terraform-${TF_VAR_environment}-$(date +%Y%m%d-%H%M%S).tfstate
```

### Audit Trail

Workflow summary includes:
- Environment destroyed
- Resources that were removed
- Timestamp of destruction
- GitHub user who requested destruction
- Reviewer who approved destruction

## Security Considerations

1. **Access control**: Only authorized personnel can access the Actions tab and run workflows
2. **Input validation**: Environment name must match confirmation to prevent typos
3. **Approval gates**: Each environment has separate required reviewers
4. **OIDC scope**: Azure credentials are scoped to subscription and authenticated with workload identity
5. **Audit logging**: GitHub Actions logs all execution and approvals
6. **State protection**: Backups are stored as artifacts (retained per GitHub policy)

## Testing Strategy

1. Test destroy plan preview (without approval, cancel before apply)
2. Test destroy on development environment first
3. Verify state backup artifact is created
4. Verify audit trail appears in workflow run

## References

- [GitHub Actions workflow dispatch](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch)
- [GitHub Actions protected environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Terraform destroy](https://www.terraform.io/cli/commands/destroy)
- [Terraform state backup](https://www.terraform.io/language/state/remote-state-backup)
