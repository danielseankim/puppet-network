module Puppet::Parser::Functions
  newfunction(:ifcfg_filepath, :type => :rvalue) do |args|
    osfam = args[0]
    path = "/etc/sysconfig/network-scripts/"
    if osfam == "Suse"
      path = "/etc/sysconfig/network/"
    end

    path
  end
end
