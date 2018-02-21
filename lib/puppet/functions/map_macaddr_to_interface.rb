Puppet::Functions.create_function(:map_macaddr_to_interface) do
  dispatch :map_macaddr_to_interface do
    param 'String', :macaddr
    return_type 'String'
  end

  def map_macaddr_to_interface(macaddr)
    interfaces = closure_scope["facts"]["networking"]["interfaces"]
    call_function("notice", "map_macaddr_to_interface.rb: find interface with mac_addr=#{macaddr} from #{interfaces}")

    interface = ""
    interfaces.each do |ifn, ifc|
      if ifn != "lo" && ifc["mac"] =~ /^(?i)#{macaddr}$/
        interface = ifn
      end
    end

    call_function("notice", "map_macaddr_to_interface.rb: Found interface: #{interface}")
    call_function("fail", "map_macaddr_to_interface.rb: Failed to find interface with with #{macaddr}") if interface == ""

    interface
  end
end

