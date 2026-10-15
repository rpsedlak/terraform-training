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

  def test_apply_is_manual_main_only_and_protected
    triggers = trigger_config(@deployment)
    apply = @deployment.dig("jobs", "apply")

    assert triggers.key?("workflow_dispatch")
    assert_includes apply["if"], "github.ref == 'refs/heads/main'"
    assert_match(/terraform-apply-/, apply.dig("environment", "name"))
    assert_equal "write", apply.dig("permissions", "id-token")
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
      assert_includes step["run"], 'TF_STATE_KEY="tftraining-${TF_VAR_environment}.tfstate"'
    end
  end

  private

  def trigger_config(workflow)
    workflow["on"] || workflow[true]
  end
end