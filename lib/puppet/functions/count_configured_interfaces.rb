Puppet::Functions.create_function(:count_configured_interfaces) do
  dispatch :count_configured_interfaces do
    param 'String', :macaddr
  end

  def count_configured_interfaces(macaddr)
    interfaces = closure_scope["facts"]["interfaces"]
    interfaces.split(",").count { |ifn| closure_scope["facts"][ifn]["mac"] =~ /^#{macaddr}$/ }
  end
end

