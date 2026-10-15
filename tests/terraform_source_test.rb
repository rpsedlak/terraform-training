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

  def test_server_nic_is_private_and_attached_to_servers_subnet
    compute = @sources.fetch("compute.tf")

    assert_match(/subnet_id\s*=\s*azurerm_subnet\.servers\.id/, compute)
    refute_match(/public_ip_address_id\s*=/, compute)
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