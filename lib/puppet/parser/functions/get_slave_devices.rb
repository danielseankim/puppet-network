module Puppet::Parser::Functions
  newfunction(:get_slave_devices, :type => :rvalue) do |args|
    result = []
    macaddresses = args[0]
    macaddresses.split(",").each do |mac|
      dev = function_map_macaddr_to_interface([mac])
      result << dev
    end

    result
  end
end
