# Terraform Destroy Workflow - Setup Checklist

## Pre-Implementation Review

- [ ] Read [ADR-022: Terraform Destroy Strategy](specs/001-terraform-ci-pipeline/decisions/ADR-022-terraform-destroy.md)
- [ ] Review [TERRAFORM_DESTROY_GUIDE.md](TERRAFORM_DESTROY_GUIDE.md)
- [ ] Review [terraform-destroy.yml workflow](.github/workflows/terraform-destroy.yml)
- [ ] Understand three-job pipeline: validate → plan-destroy → destroy

## GitHub Repository Configuration

### Protected Environments

You need to create **three new protected environments** in GitHub Settings.

#### Environment 1: terraform-destroy-development

**Location:** Settings → Environments → New environment

**Configuration:**
- [ ] Name: `terraform-destroy-development`
- [ ] Enable "Deployment branches and secrets"
- [ ] Deployment branch restrictions: `development-20261015` only
- [ ] Add required reviewers (minimum 1)
  - Suggested: Dev team lead
- [ ] No secrets required (uses vars. which are already configured)
- [ ] Save environment

#### Environment 2: terraform-destroy-testing

**Location:** Settings → Environments → New environment

**Configuration:**
- [ ] Name: `terraform-destroy-testing`
- [ ] Enable "Deployment branches and secrets"
- [ ] Deployment branch restrictions: `main` only
- [ ] Add required reviewers (minimum 1)
  - Suggested: QA team lead
- [ ] No secrets required
- [ ] Save environment

#### Environment 3: terraform-destroy-production

**Location:** Settings → Environments → New environment

**Configuration:**
- [ ] Name: `terraform-destroy-production`
- [ ] Enable "Deployment branches and secrets"
- [ ] Deployment branch restrictions: `main` only
- [ ] Add required reviewers (minimum 2 recommended)
  - Suggested: Release manager + Infrastructure lead
- [ ] No secrets required
- [ ] Save environment

### Verify Existing Variables

The destroy workflow uses the same variables as plan/apply jobs:

- [ ] `AZURE_PLAN_CLIENT_ID` - Already configured
- [ ] `AZURE_TENANT_ID` - Already configured
- [ ] `AZURE_SUBSCRIPTION_ID` - Already configured
- [ ] `AZURE_KEY_VAULT_NAME` - Already configured
- [ ] `TF_STATE_RESOURCE_GROUP` - Already configured

**No new variables needed** - reuses existing configuration from ADR-012.

## Workflow Files

### Implementation Files (Already Added)

- [x] `.github/workflows/terraform-destroy.yml` - Workflow implementation
- [x] `specs/001-terraform-ci-pipeline/decisions/ADR-022-terraform-destroy.md` - Architecture decision record
- [x] `specs/001-terraform-ci-pipeline/plan-destroy.md` - Technical specification
- [x] `TERRAFORM_DESTROY_GUIDE.md` - User guide

**Verification:**
- [ ] Workflow file exists: `.github/workflows/terraform-destroy.yml`
- [ ] Workflow syntax is valid (GitHub Actions tab shows no errors)
- [ ] All documentation files are readable

## User Access & Training

### For All Users (Who May Request Destruction)

- [ ] Share link to [TERRAFORM_DESTROY_GUIDE.md](TERRAFORM_DESTROY_GUIDE.md)
- [ ] Review quick start section (top of guide)
- [ ] Understand branch requirements:
  - `development-20261015` for development destruction
  - `main` for testing/production destruction
- [ ] Understand confirmation requirement (must type environment name exactly)
- [ ] Know how to review destruction plan before approval
- [ ] Know how to recover if accidental destruction occurs

### For Approvers (Required Reviewers)

- [ ] Configure approvers in protected environments (Settings → Environments)
- [ ] Review entire [TERRAFORM_DESTROY_GUIDE.md](TERRAFORM_DESTROY_GUIDE.md)
- [ ] Understand approval workflow:
  1. Workflow notifies when waiting for approval
  2. Navigate to Actions → workflow run
  3. Click "Review deployments"
  4. Review destruction plan summary
  5. Click "Approve and deploy" or "Reject"
- [ ] Understand backup recovery procedures
- [ ] Know how to reach other approvers for consultation
- [ ] Document approval chain (who approves what)

## Testing & Validation

### Pre-Production Tests

**Test 1: Workflow Triggers**
- [ ] Go to Actions tab
- [ ] Find "Terraform Destroy" workflow
- [ ] Verify "Run workflow" button is available
- [ ] Verify input options appear (environment, confirmation, backup)

**Test 2: Input Validation (Development)**
- [ ] Checkout `development-20261015` branch
- [ ] Run workflow with:
  - Environment: `development`
  - Confirmation: `development` (correct)
  - Backup: enabled
- [ ] Verify validation job passes
- [ ] Cancel before plan-destroy completes
- [ ] ✓ This just validates inputs, no destruction

**Test 3: Plan Preview (Development)**
- [ ] Run workflow again on `development-20261015`
- [ ] Let plan-destroy job complete
- [ ] Review job summary showing resources to destroy
- [ ] Verify state backup artifact is created
- [ ] Download and verify backup file (should be valid JSON)
- [ ] Do NOT approve (we're just testing the plan)
- [ ] Let job timeout or manually reject

**Test 4: Branch Restriction Validation**
- [ ] Checkout `main` branch
- [ ] Try to run destroy with environment: `development`
- [ ] Verify validation job fails with message:
  ```
  ERROR: Development destroy can only be triggered from development-20261015 branch
  ```
- [ ] ✓ Branch protection is working

**Test 5: Confirmation Validation**
- [ ] Checkout `development-20261015`
- [ ] Run with environment: `development` but confirmation: `dev` (typo)
- [ ] Verify validation job fails with message:
  ```
  ERROR: Environment confirmation does not match selected environment
  ```
- [ ] ✓ Confirmation protection is working

### Full End-to-End Test (Development Only)

**Prerequisites:**
- [ ] All three protected environments are configured with approvers
- [ ] All approvers understand the approval workflow
- [ ] State backup has been tested and verified

**Procedure:**
1. [ ] Checkout `development-20261015` branch
2. [ ] Go to Actions → Terraform Destroy → Run workflow
3. [ ] Enter inputs:
   - Environment: `development`
   - Confirmation: `development`
   - Backup: enabled
4. [ ] Click "Run workflow"
5. [ ] Wait for validation job (should pass)
6. [ ] Wait for plan-destroy job to complete
7. [ ] Review destruction plan in job summary
8. [ ] Ask an approver to review and approve
9. [ ] Approver navigates to workflow → Review deployments → Approve
10. [ ] Watch destroy job execute
11. [ ] Verify completion report appears in job summary
12. [ ] Verify resources are removed in Azure portal
13. [ ] Verify state backup artifact is available for 30 days

**After Test:**
- [ ] Redeploy development environment
  - Option A: Run Terraform Plan/Apply workflow
  - Option B: Merge PR to development-20261015 branch
- [ ] Verify resources are recreated
- [ ] ✓ Destroy and recovery process works end-to-end

## Documentation Sharing

### Team Communication

- [ ] Link to [TERRAFORM_DESTROY_GUIDE.md](TERRAFORM_DESTROY_GUIDE.md) in team Slack/email
- [ ] Share [ADR-022](specs/001-terraform-ci-pipeline/decisions/ADR-022-terraform-destroy.md) with technical leads
- [ ] Add link to README.md or operations runbook
- [ ] Document in internal wiki/knowledge base

### Training Materials

- [ ] Create runbook entry for infrastructure teardown
- [ ] Document cost optimization procedures
- [ ] Document disaster recovery procedures
- [ ] Create approval chain flowchart
- [ ] Add to incident response playbooks

## Operational Setup

### Monitoring & Alerts

- [ ] Configure GitHub notifications for workflow runs
- [ ] Set up Slack bot to alert on destroy workflow triggers (optional)
- [ ] Document who gets notified for each environment
- [ ] Create escalation path if approval is urgent

### State Backup Procedures

- [ ] Verify state backups are retained for 30 days
- [ ] Document backup artifact location
- [ ] Create process for archiving backups beyond 30 days
- [ ] Document recovery procedures in runbook

### Audit & Compliance

- [ ] Document that all destroy operations are logged in GitHub Actions
- [ ] Verify Azure activity logs capture resource deletions
- [ ] Create process for reviewing destroy operations
- [ ] Document retention policy for logs
- [ ] Add destroy operations to change log/audit trail

## Verification Checklist

**After completing all setup:**

- [ ] Protected environments exist in Settings → Environments
  - [ ] terraform-destroy-development
  - [ ] terraform-destroy-testing
  - [ ] terraform-destroy-production
- [ ] Each environment has correct branch restrictions
- [ ] Each environment has required reviewers configured
- [ ] Workflow file exists and has valid YAML syntax
- [ ] Documentation is accessible to team
- [ ] All users understand the process
- [ ] All approvers know how to review and approve
- [ ] Input validation is tested (typos caught)
- [ ] Branch restrictions are tested
- [ ] Full end-to-end test completed on development
- [ ] Backup and recovery procedures are tested
- [ ] Team is trained and ready

## Go/No-Go Decision

**Ready for production use?**

Checklist complete: **[  ]** YES or **[  ]** NO

If NO, what's remaining?
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**Approved by:** _____________________ **Date:** _______________

**Sign-off:** I confirm that all items have been completed and the destroy workflow is ready for production use.

---

## Quick Reference

### URLs
- **Workflow:** `https://github.com/rpsedlak/terraform-training/actions/workflows/terraform-destroy.yml`
- **Settings (Environments):** `https://github.com/rpsedlak/terraform-training/settings/environments`
- **User Guide:** [TERRAFORM_DESTROY_GUIDE.md](TERRAFORM_DESTROY_GUIDE.md)
- **ADR-022:** [specs/001-terraform-ci-pipeline/decisions/ADR-022-terraform-destroy.md](specs/001-terraform-ci-pipeline/decisions/ADR-022-terraform-destroy.md)

### Branch Mapping
- **development** → run from `development-20261015` branch
- **testing** → run from `main` branch
- **production** → run from `main` branch

### Environment Variables (Pre-configured)
```
AZURE_PLAN_CLIENT_ID: [already set]
AZURE_TENANT_ID: [already set]
AZURE_SUBSCRIPTION_ID: [already set]
AZURE_KEY_VAULT_NAME: [already set]
TF_STATE_RESOURCE_GROUP: [already set]
```

### Protected Environments (Must Create)
```
terraform-destroy-development
terraform-destroy-testing
terraform-destroy-production
```
