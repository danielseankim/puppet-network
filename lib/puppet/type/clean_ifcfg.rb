# This type is loosely based on Puppet's tidy resource. The tidy resource does not really support excluding filename patterns.
Puppet::Type.newtype(:clean_ifcfg) do
  desc "Deletes all ifcfg- files in /etc/sysconfig/network-scripts that do not have a name that matches our list to ignore"
  newparam(:name)

  newparam(:ignore) do
    @doc = "List of interfaces that we don't want to leave ifcfg files for"
    if Puppet.version.start_with?("4.")
      defaultto Facter.value(:interfaces).to_s
    else
      defaultto Facter["interfaces"].value.to_s
    end
    validate do |value|
      raise ("ignore parameter must be a comma separated string of interface names") unless value.is_a?(String)
      super(value)
    end
    munge do |value|
      value.split(",").map(&:strip)
    end
  end

  def eval_generate
    # Do this only for the VM's since pxe_cleanup.pp handles baremetal server's PXE cleanup
    # Since different facter versions can return the value as a string/boolean, check for both.
    is_virtual = get_facter_value("is_virtual")
    notice "This node is a #{get_facter_value("virtual")} machine.. is_virtual = #{is_virtual}"
    return [] unless is_virtual == "true"

    # disable the removal of bond config
    osfam = get_facter_value("osfamily")
    ifcfg_dir = (osfam == "RedHat") ? "/etc/sysconfig/network-scripts" : "/etc/sysconfig/network"
    ifcfg_bond_file = Dir["#{ifcfg_dir}/ifcfg-bond*"]
    return [] unless ifcfg_bond_file.empty?

    ifcfg_files = Dir["#{ifcfg_dir}/ifcfg-*"]
    # ignore ifcfg-lo, as well as any ifcfg file for an interface we have said to ignore
    ifcfg_files.reject! do |file|
      file.end_with?("-lo") || self[:ignore].find{ |name| file.end_with?("-%s" % name)}
    end
    return [] if ifcfg_files.empty?
    notice "Cleaning ifcfg files: %s" % ifcfg_files.to_s
    ifcfg_files.collect { |path| mk_file_resource(path) }
  end

  # Reused from Puppet's tidy resource code
  # Make a file resource to remove a given file.
  def mk_file_resource(path)
    # Force deletion, so directories actually get deleted.
    Puppet::Type.type(:file).new :path => path, :ensure => :absent, :force => true, :before => self[:before]
  end

  # Return facter key
  #
  # This is a helper method in order to support multiple versions
  # of facter depending on the puppet version
  #
  # @param key [String]
  # @return [String]
  def get_facter_value(key)
    if Puppet.version.start_with?("4.")
      Facter.value(key.to_sym).to_s
    else
      Facter[key].value.to_s
    end
  end
end
