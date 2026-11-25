# Terraform Destroy Workflow Guide

**⚠️ WARNING: This workflow permanently destroys infrastructure. Exercise extreme caution.**

## Overview

The `Terraform Destroy` workflow allows authorized personnel to safely and auditably remove managed infrastructure from Azure environments (development, testing, or production).

### Key Safety Features

- ✅ **Manual-only trigger**: Never automatic, always explicit
- ✅ **Environment confirmation**: Must type environment name to confirm
- ✅ **Branch restrictions**: Development only from `development-20261015`; testing/production only from `main`
- ✅ **Approval gates**: Each environment has separate required reviewers
- ✅ **State backup**: Automatic backup of Terraform state before destruction
- ✅ **Plan review**: Destroy plan shows all resources to be removed before approval
- ✅ **Audit trail**: Full logging of who requested destruction and when

---

## Quick Start

### Step 1: Navigate to the Destroy Workflow

1. Go to your repository: https://github.com/rpsedlak/terraform-training
2. Click the **Actions** tab
3. Find **"Terraform Destroy"** in the left sidebar
4. Click on it

### Step 2: Trigger the Workflow

1. Click the **"Run workflow"** button (blue button on the right)
2. A form will appear with three required fields

### Step 3: Fill in the Form

You'll see these inputs:

| Field | Required | Options | Purpose |
|-------|----------|---------|---------|
| **Azure environment to destroy** | Yes | `development` / `testing` / `production` | Select which environment to destroy |
| **Type the environment name to confirm** | Yes | Freetext | Type exactly what you selected above (prevents accidents) |
| **Create state backup before destroying** | No | Checkbox (default: true) | Whether to backup state first (recommended) |

### Step 4: Select Environment

Choose one of:
- **development** - destroys dev resources from `development-20261015` branch
- **testing** - destroys test resources from `main` branch
- **production** - destroys prod resources from `main` branch

**Example for development:**
```
Environment: development
Confirmation: development
Backup: ☑ (checked)
```

### Step 5: Type Environment Confirmation

This is a **safety feature** to prevent accidents. You must type the exact environment name you selected.

If you selected `development`, type `development` in the confirmation field.

**Common mistakes to avoid:**
- ❌ Typing `dev` instead of `development`
- ❌ Typing the wrong environment name
- ❌ Copying from somewhere else with extra spaces
- ❌ Uppercase instead of lowercase

### Step 6: Review and Click "Run workflow"

After you've filled in all fields correctly, click the green **"Run workflow"** button at the bottom.

---

## What Happens Next

### Phase 1: Validation (Automatic)

The workflow will:
1. Confirm environment name matches your confirmation input
2. Verify you're on the correct branch
   - **development** must be run from `development-20261015` branch
   - **testing/production** must be run from `main` branch

**If validation fails:** The workflow stops immediately with an error message.

### Phase 2: Plan & Backup (Automatic)

The workflow will:
1. Authenticate to Azure using OIDC
2. Connect to your Terraform remote state
3. **Create a backup of current state** (saved as artifact for 30 days)
4. Run `terraform plan -destroy` to show all resources that will be removed

**You'll see:**
- A list of all resources to be destroyed
- Number of resources being removed
- Terraform initialization details

### Phase 3: Review Destroy Plan

The workflow automatically posts to the GitHub job summary showing:

```
⚠️ Terraform Destroy Plan for [environment]

Environment: `[environment]`
Resources to destroy: N
Branch: `main` or `development-20261015`
Requested by: @[your-username]
Triggered at: 2026-11-25 12:00:00 UTC

Resources that will be destroyed:
- `azurerm_resource_group.environment`
- `azurerm_virtual_network.environment`
- `azurerm_subnet.servers`
- ... etc
```

**🛑 PAUSE HERE!**

**Review this plan carefully.** This is your last chance to cancel before execution.

### Phase 4: Approval (Required)

If the plan looks correct, the workflow waits for approval from required reviewers (configured in GitHub protected environments).

**Workflow will block at:**
```
Waiting for approval from reviewers in environment 'terraform-destroy-[environment]'
```

A GitHub notification is sent to configured reviewers.

**Reviewers must:**
1. Navigate to the workflow run
2. Review the destruction plan
3. Click **"Review deployments"**
4. Click **"Approve and deploy"**

**To cancel before execution:**
1. Click **"Review deployments"**
2. Click **"Reject"**

### Phase 5: Execute Destroy (After Approval)

Once approved, the workflow:
1. Authenticates to Azure again
2. Runs `terraform destroy -auto-approve`
3. All managed resources are **permanently removed**
4. Posts completion report to job summary

---

## Example: Destroy Development Environment

### Before Starting
- You are on `development-20261015` branch
- You have write access to the repository Actions
- You have confirmed the environment is not in use

### Steps

1. Go to Actions → Terraform Destroy → Run workflow
2. Fill in the form:
   ```
   Environment: development
   Confirmation: development
   Create state backup: ☑
   ```
3. Click "Run workflow"
4. **Wait for the validation and plan phase** (usually 2-3 minutes)
5. Review the destruction plan in the GitHub job summary
6. When ready, ask a required reviewer to approve
7. Reviewer navigates to the workflow and clicks "Approve and deploy"
8. Infrastructure is destroyed

---

## Branch Requirements

**You must be on the correct branch when triggering destroy:**

| Environment | Branch | Command |
|-------------|--------|---------|
| development | `development-20261015` | `git checkout development-20261015` |
| testing | `main` | `git checkout main` |
| production | `main` | `git checkout main` |

**Example error if on wrong branch:**
```
ERROR: Development destroy can only be triggered from development-20261015 branch
Current branch: main
```

---

## State Backup and Recovery

### Automatic Backup

Before any destruction, the workflow automatically:
1. Downloads your current Terraform state
2. Saves it with a timestamp
3. Uploads it as a GitHub artifact

**Artifact location:**
- Workflow run → Artifacts section
- Named: `terraform-state-backup-[environment]-[run-id]`
- Retained for 30 days

### Manual Recovery (If Needed)

If you need to recover from an accidental destruction:

1. **Download the state backup artifact**
   - Go to the workflow run
   - Scroll to Artifacts section
   - Download the backup file

2. **Restore to remote state**
   ```bash
   # Replace [file] with downloaded backup
   # WARNING: This overwrites current state!
   terraform -chdir=infra state push [file]
   ```

3. **Reapply infrastructure**
   ```bash
   git push origin [branch]  # Trigger automatic deployment
   # Or manually run Terraform Plan and Apply workflow
   ```

---

## Troubleshooting

### "Environment confirmation does not match selected environment"

**Problem:** The confirmation field doesn't exactly match the environment you selected.

**Solution:**
- Selected: `development`
- Confirmation must be: `development` (exactly)
- Not: `dev`, `Development`, `DEVELOPMENT`, or anything else

### "Development destroy can only be triggered from development-20261015 branch"

**Problem:** You selected development but you're not on the right branch.

**Solution:**
```bash
git checkout development-20261015
```

Then run the workflow again.

### "Testing and production destroy can only be triggered from main branch"

**Problem:** You selected testing or production but you're not on the main branch.

**Solution:**
```bash
git checkout main
```

Then run the workflow again.

### Workflow keeps getting skipped

**Problem:** The validation job is failing silently.

**Solution:**
1. Click on the workflow run
2. Expand the "Validate destroy request" section
3. Look for error messages
4. Most common: environment confirmation typo

### How do I cancel if I realize I made a mistake?

**Before approval:**
- The workflow will be waiting for reviewers to approve
- Just don't approve it, and it will time out or can be manually rejected

**After approval but before it starts destroying:**
- Click on the "destroy" job
- If it hasn't started executing yet, you can cancel
- Click the "Cancel workflow" button on the left

**After destruction is complete:**
- Use the state backup artifact to recover
- Reapply infrastructure by pushing to the branch

---

## Audit Trail

Every destroy operation creates an audit trail visible in:

1. **GitHub Actions workflow run**
   - Timestamp: when workflow was triggered
   - Triggered by: GitHub username
   - Workflow logs: all steps executed
   - Job summaries: plan and execution reports

2. **Git commit history**
   - Shows which branch destroy was triggered from
   - Visible in `git log`

3. **Azure Activity Log**
   - Resource deletion events
   - Timestamps and operations

---

## Protected Environments

Three separate protected environments enforce approval requirements:

| Environment | Environment Name | Reviewers | Purpose |
|-------------|------------------|-----------|---------|
| Development | `terraform-destroy-development` | Dev team lead | Approve dev destruction |
| Testing | `terraform-destroy-testing` | QA team lead | Approve test destruction |
| Production | `terraform-destroy-production` | Multiple approvers | Approve production destruction |

**Configure reviewers:**
- Repository Settings → Environments
- Select the environment
- Add required reviewers under "Deployment branches and secrets"

---

## Safety Best Practices

### Before You Destroy

- ✅ Confirm the environment is not in production use
- ✅ Notify team members who might be affected
- ✅ Review the destruction plan carefully
- ✅ Have the state backup downloaded
- ✅ Double-check the environment name

### During Destruction

- ✅ Watch the workflow progress
- ✅ Monitor Azure portal for resource deletion
- ✅ Check error messages if anything fails

### After Destruction

- ✅ Verify all resources are removed in Azure portal
- ✅ Document why the environment was destroyed
- ✅ Check for any manually created resources that weren't managed by Terraform
- ✅ Archive the state backup if needed for compliance

---

## Related Documentation

- **[ADR-022: Terraform Destroy Strategy](../decisions/ADR-022-terraform-destroy.md)** - Design decisions
- **[Terraform Destroy Documentation](https://www.terraform.io/cli/commands/destroy)** - Official Terraform docs
- **[GitHub Actions Documentation](https://docs.github.com/en/actions)** - Workflow details

---

## Questions?

Before running destroy on production:
1. Read this entire guide
2. Test on development first
3. Get approval from your team
4. Document your plan
5. Have recovery procedures ready

**When in doubt, ask before you destroy.**
