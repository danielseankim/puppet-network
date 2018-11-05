Puppet::Type.type(:check_interface).provide(:check_interface) do
  def exists?
    invalid_interfaces.empty?
  end

  def create
    begin
      Puppet.info("Result for interface check: %s" % invalid_interfaces)

      return if invalid_interfaces.empty?
      raise "These interfaces do not have valid IP address: %s" % invalid_interfaces if resource[:operation] == :noop

      invalid_interfaces.collect { |interface| restart_interface(interface) } if resource[:operation] == :restart_interface
    rescue
      Puppet.err("Failed to reconfigure invalid interface due to this following error, %s:%s" % [$!.class, $!.message])
      raise $!
    end
  end

  def destroy
    # nothing to do here
  end

  private

  def invalid_interfaces
    @interfaces_to_fix ||= find_invalid_interfaces
  end

  def find_invalid_interfaces
    # Do this only for the SVM - it must be virtual machine with Suse 12 OS
    is_virtual = get_facter_value("is_virtual")
    osfamily = get_facter_value("osfamily")
    operatingsystemrelease = get_facter_value("operatingsystemrelease")
    @result = []

    return @result unless is_virtual == "true" && osfamily.downcase == "suse" && operatingsystemrelease =~ /^12/

    interfaces = get_facter_value("interfaces").split(",").map(&:strip)
    interfaces.each do |interface|
      next if interface == "lo"

      ip = get_facter_value("ipaddress_%s" % interface)
      Puppet.info( "IP address of %s is %s" % [interface, ip])

      if ip.nil? || ip.empty?
        @result << interface
      end
    end

    @result
  end

  # Restart the interface
  #
  # Restart the interface by calling system, since puppet won't refresh network as it fails to detect
  # failure in Suse 12 OS.
  #
  # @param interface the name of the interface
  # @raise error if the interface still lacks a valid IP address after restarting it
  def restart_interface(interface)
    # Force deletion, so directories actually get deleted.
    Puppet.info( "Restarting interface %s" % interface)
    system("ifdown %s" % interface)
    sleep 15
    system("ifup %s" % interface) || raise("Restarting interface failed!")

    ip = get_facter_value("ipaddress_%s" % interface)
    Puppet.info( "IP address of %s is %s" % [interface, ip])
    if ip.nil? || ip.empty?
      raise "Restarted interface, %s, but it did not get a valid IP address." % interface
    end
  end

  # Return facter key
  #
  # This is a helper method in order to support multiple versions
  # of facter depending on the puppet version
  #
  # @param key [String]
  # @return [String]
  def get_facter_value(key)
    Facter.value(key.to_sym).to_s
  end
end
