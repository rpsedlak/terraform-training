require "minitest/autorun"
require "yaml"

class WorkflowsTest < Minitest::Test
  WORKFLOW_DIRECTORY = File.expand_path("../.github/workflows", __dir__)

  def setup
    @ci = YAML.load_file(File.join(WORKFLOW_DIRECTORY, "terraform-ci.yml"))
    @deployment = YAML.load_file(File.join(WORKFLOW_DIRECTORY, "terraform-deploy.yml"))
  end

  def test_ci_runs_for_pull_requests_and_main
    triggers = trigger_config(@ci)

    assert_equal ["main"], triggers.dig("pull_request", "branches")
    assert_equal ["main"], triggers.dig("push", "branches")
    assert_equal "read", @ci.dig("permissions", "contents")
  end

  def test_ci_validates_and_tests_infra_root
    steps = @ci.dig("jobs", "validate", "steps")

    assert_includes steps.map { |step| step["run"] }.compact, "terraform -chdir=infra fmt -check -recursive -no-color"
    assert_includes steps.map { |step| step["run"] }.compact, "terraform -chdir=infra validate -no-color"
    assert_includes steps.map { |step| step["run"] }.compact, "terraform -chdir=infra test -no-color"
  end

  def test_privileged_plan_excludes_fork_pull_requests
    plan = @deployment.dig("jobs", "plan")

    assert_includes plan["if"], "github.event.pull_request.head.repo.full_name == github.repository"
    assert_equal "write", plan.dig("permissions", "id-token")
    assert_match(/terraform-plan-/, plan.dig("environment", "name"))
  end

  def test_pull_request_plan_requires_complete_azure_configuration
    plan = @deployment.dig("jobs", "plan")

    %w[
      AZURE_PLAN_CLIENT_ID
      AZURE_TENANT_ID
      AZURE_SUBSCRIPTION_ID
      AZURE_KEY_VAULT_NAME
      TF_STATE_RESOURCE_GROUP
    ].each do |variable|
      assert_includes plan["if"], "vars.#{variable} != ''"
    end
    assert_includes plan["if"], "github.event_name == 'workflow_dispatch'"
  end

  def test_apply_is_manual_environment_branch_restricted_and_protected
    triggers = trigger_config(@deployment)
    apply = @deployment.dig("jobs", "apply")
    vm_size_input = triggers.dig("workflow_dispatch", "inputs", "vm_size")

    assert triggers.key?("workflow_dispatch")
    assert_includes apply["if"], "github.ref == 'refs/heads/main'"
    assert_match(/terraform-apply-/, apply.dig("environment", "name"))
    assert_equal "write", apply.dig("permissions", "id-token")
    assert_equal "Standard_D2ds_v6", vm_size_input["default"]
    assert_includes vm_size_input["options"], "Standard_D2ds_v6"
  end

  def test_manual_plan_and_apply_use_exact_environment_branch_guards
    manual_guard = <<~CONDITION.split.join(" ")
      github.event_name == 'workflow_dispatch' &&
      ((inputs.environment == 'development' && github.ref == 'refs/heads/development-20261015') ||
      ((inputs.environment == 'testing' || inputs.environment == 'production') && github.ref == 'refs/heads/main'))
    CONDITION
    pull_request_guard = <<~CONDITION.split.join(" ")
      (github.event_name == 'pull_request' && github.event.pull_request.head.repo.full_name == github.repository &&
      vars.AZURE_PLAN_CLIENT_ID != '' && vars.AZURE_TENANT_ID != '' &&
      vars.AZURE_SUBSCRIPTION_ID != '' && vars.AZURE_KEY_VAULT_NAME != '' &&
      vars.TF_STATE_RESOURCE_GROUP != '')
    CONDITION

    assert_equal manual_guard, @deployment.dig("jobs", "apply", "if").split.join(" ")
    assert_equal "#{pull_request_guard} || (#{manual_guard})", @deployment.dig("jobs", "plan", "if").split.join(" ")
  end

  def test_both_jobs_read_and_mask_fixed_key_vault_secrets
    %w[plan apply].each do |job_name|
      job = @deployment.dig("jobs", job_name)
      steps = job.fetch("steps")
      login_index = steps.index { |step| step["uses"] == "azure/login@v2" }
      credentials_index = steps.index { |step| step["id"] == "vm_admin" }
      credential_step = steps.fetch(credentials_index)

      assert_operator login_index, :<, credentials_index
      assert_includes credential_step["run"], "--name adminuser"
      assert_includes credential_step["run"], "--name adminpassword"
      assert_includes credential_step["run"], "::add-mask::"
      refute job.fetch("env", {}).key?("TF_VAR_vm_admin_password")
      refute job.fetch("env", {}).key?("TF_VAR_vm_admin_username")
    end
  end

  def test_terraform_receives_key_vault_step_outputs
    plan = @deployment.dig("jobs", "plan", "steps").find { |step| step["id"] == "plan" }
    apply = @deployment.dig("jobs", "apply", "steps").find { |step| step["name"] == "Replan, compare summary, and apply" }

    [plan, apply].each do |step|
      assert_equal "${{ steps.vm_admin.outputs.username }}", step.dig("env", "TF_VAR_vm_admin_username")
      assert_equal "${{ steps.vm_admin.outputs.password }}", step.dig("env", "TF_VAR_vm_admin_password")
    end

    assert_equal "${{ inputs.vm_size || 'Standard_D2ds_v6' }}", @deployment.dig("jobs", "plan", "env", "TF_VAR_vm_size")
    assert_equal "${{ inputs.vm_size }}", @deployment.dig("jobs", "apply", "env", "TF_VAR_vm_size")
  end

  def test_apply_replans_and_compares_summary_before_applying
    apply = @deployment.dig("jobs", "apply", "steps").find { |step| step["name"] == "Replan, compare summary, and apply" }
    run_script = apply.fetch("run")

    assert_operator run_script.index("current_summary"), :<, run_script.index("terraform -chdir=infra apply")
    assert_includes run_script, "EXPECTED_PLAN_SUMMARY"
  end

  def test_plan_summary_omits_attribute_values
    plan = @deployment.dig("jobs", "plan", "steps").find { |step| step["id"] == "plan" }
    run_script = plan.fetch("run")

    assert_includes run_script, "changed_attributes"
    assert_includes run_script, "Only changed attribute names are shown; attribute values are intentionally omitted."
  end

  def test_state_backend_uses_expected_account_container_and_separate_keys
    assert_equal "dizzyterraform20261014", @deployment.dig("env", "TF_STATE_STORAGE_ACCOUNT")
    assert_equal "tfstate", @deployment.dig("env", "TF_STATE_CONTAINER")

    plan_init = @deployment.dig("jobs", "plan", "steps").find { |step| step["name"] == "Initialize remote state" }
    apply_init = @deployment.dig("jobs", "apply", "steps").find { |step| step["name"] == "Initialize remote state" }

    [plan_init, apply_init].each do |step|
      assert_equal "bash", step["shell"], "Bash backend initialization must not use the Windows default shell"
      assert_includes step["run"], 'TF_STATE_KEY="tftraining-${TF_VAR_environment}.tfstate"'
    end
  end

  private

  def trigger_config(workflow)
    workflow["on"] || workflow[true]
  end
end