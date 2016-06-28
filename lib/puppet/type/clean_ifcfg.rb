# This type is loosely based on Puppet's tidy resource. The tidy resource does not really support excluding filename patterns.
Puppet::Type.newtype(:clean_ifcfg) do
  desc "Deletes all ifcfg- files in /etc/sysconfig/network-scripts that do not have a name that matches our list to ignore"
  newparam(:name)

  newparam(:ignore) do
    @doc = "List of interfaces that we don't want to leave ifcfg files for"
    defaultto Facter["interfaces"].value
    validate do |value|
      raise ("ignore parameter must be a comma separated string of interface names") unless value.is_a?(String)
      super(value)
    end
    munge do |value|
      value.split(",").map(&:strip)
    end
  end

  def eval_generate
    # disable the removal of bond config - rest can be ignored since baremetal server does not require ifcfg cleanup anyway
    osfam = Facter["osfamily"].value
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
end
