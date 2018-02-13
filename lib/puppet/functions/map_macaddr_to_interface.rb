Puppet::Functions.create_function(:map_macaddr_to_interface) do
  dispatch :map_macaddr_to_interface do
    param 'String', :macaddr
  end

  def map_macaddr_to_interface(macaddr)
    interfaces = closure_scope["facts"]["interfaces"]
    interfaces.split(",").find { |ifn| closure_scope["facts"]["networking"]["interfaces"][ifn]["mac"] =~ /^(?i)#{macaddr}$/ }
  end
end

