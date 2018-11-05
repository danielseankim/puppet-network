Puppet::Type.newtype(:check_interface) do
  @doc = "Check if interface is up with valid IP address for Suse 12 VMs"

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name, :namevar=>true) do
    desc "Name of the check_interface resource"
  end

  newparam(:operation) do
    desc "Operation mode for handling invalid interface"
    newvalues(:noop, :restart_interface)
    defaultto :noop
  end

end
