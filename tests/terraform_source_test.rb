require "minitest/autorun"

class TerraformSourceTest < Minitest::Test
  INFRA_DIRECTORY = File.expand_path("../infra", __dir__)

  def setup
    @sources = Dir.glob(File.join(INFRA_DIRECTORY, "*.tf")).to_h do |path|
      [File.basename(path), File.read(path)]
    end
    @source = @sources.values.join("\n")
  end

  def test_environment_has_exactly_one_vnet_and_one_windows_vm
    assert_equal 1, resource_count("azurerm_virtual_network")
    assert_equal 1, resource_count("azurerm_windows_virtual_machine")
  end

  def test_environment_does_not_declare_a_virtual_network_gateway
    refute_match(/resource\s+"azurerm_virtual_network_gateway"/, @source)
    refute_includes @source, '"GatewaySubnet"'
  end

  def test_server_nic_has_public_ip_and_attached_subnet_nsg
    compute = @sources.fetch("compute.tf")

    assert_match(/subnet_id\s*=\s*azurerm_subnet\.servers\.id/, compute)
    assert_match(/public_ip_address_id\s*=\s*azurerm_public_ip\.server\.id/, compute)
    assert_includes compute, "depends_on = [azurerm_subnet_network_security_group_association.servers]"
    assert_equal 1, resource_count("azurerm_public_ip")
  end

  def test_bastion_resources_and_subnet_are_removed
    assert_equal 0, resource_count("azurerm_bastion_host")
    assert_equal 1, resource_count("azurerm_subnet")
    refute_includes @sources.fetch("network.tf"), "AzureBastionSubnet"
    refute_includes @sources.fetch("locals.tf"), "bastion"
  end

  def test_terraform_owns_only_source_restricted_rdp_rules
    compute = @sources.fetch("compute.tf")

    assert_equal 2, compute.scan(/security_rule\s*\{/).length
    assert_match(/server_rdp_source_cidr\s*=\s*"69\.244\.159\.36\/32"/, @sources.fetch("locals.tf"))
    assert_match(/name\s*=\s*"AllowRdpFromTrustedPublicIp"[^}]*access\s*=\s*"Allow"[^}]*source_address_prefix\s*=\s*local\.server_rdp_source_cidr/m, compute)
    assert_match(/name\s*=\s*"DenyRdpFromOtherSources"[^}]*access\s*=\s*"Deny"[^}]*source_address_prefix\s*=\s*"\*"/m, compute)
    refute_match(/ignore_changes\s*=/, compute)
  end

  def test_jit_and_paid_security_prerequisites_are_removed
    refute_match(/azapi|jit|defender|access_prerequisites|security_center_subscription_pricing/i, @source)
    refute_includes File.read(File.join(INFRA_DIRECTORY, ".terraform.lock.hcl")), "azure/azapi"
    assert_includes @sources.fetch("backend.tf"), 'resource_provider_registrations = "none"'
    assert_equal 0, resource_count("terraform_data")
  end

  def test_vm_password_is_marked_sensitive
    variables = @sources.fetch("variables.tf")

    assert_match(/variable\s+"vm_admin_password"\s*\{[^}]*sensitive\s*=\s*true/m, variables)
  end

  def test_no_data_disk_is_declared
    refute_match(/data_disk\s*\{/, @source)
  end

  private

  def resource_count(type)
    @source.scan(/^\s*resource\s+"#{Regexp.escape(type)}"\s+"/).length
  end
end