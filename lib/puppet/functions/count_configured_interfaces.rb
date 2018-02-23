Puppet::Functions.create_function(:count_configured_interfaces) do
  dispatch :count_configured_interfaces do
    param 'String', :macaddr
    return_type 'Numeric'
  end

  def count_configured_interfaces(macaddr)
    interfaces = closure_scope["facts"]["networking"]["interfaces"]
    call_function("notice", "count_configured_interfaces.rb: counting interface(s) with mac_addr=#{macaddr} from #{interfaces}")
    interfaces.select { |ifn| ifn["mac"] =~ /^(?i)#{macaddr}$/ unless ifn == "lo" }.keys.count
  end
end

