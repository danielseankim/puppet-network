Puppet::Functions.create_function(:ifcfg_filepath) do
  dispatch :ifcfg_filepath do
    param 'String', :osfam
  end

  def ifcfg_filepath(osfam)
    path = "/etc/sysconfig/network-scripts/"
    if osfam == "Suse"
      path = "/etc/sysconfig/network/"
    end
    path
  end
end
