# == Definition: network::suse_routes
#
# Configures /etc/sysconfig/network/routes (SLES only)
# === Authors:
#
# Daniel Kim <kdaniel@vmware.com>
#
# === Copyright:
#
# Copyright (C) 2016 Dell, Inc.
#
class network::suse_routes (
  $gateway,
  $netmask,
  $device,
) {

  # Validate our data
  if $gateway {
    if ! is_ip_address($gateway) { fail("${gateway} is not an IP address.") }
  }
  include '::network'

  # ASM: For baremetal server, the name is the mac address of the port or partition.
  #      For VM deployment, the name is always the sequence of the network interface.
  if (type($device) == "integer") {
    $interface = get_seq_interface($device)
  } elsif is_mac_address($device) {
    $interface = map_macaddr_to_interface($device)
    if !$interface {
      fail('Could not find the interface name for the given macaddress/sequence...')
    }
  } else {
    $interface = $device
  }

  include '::network'

  file { "routes":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network/routes",
    content => template('network/routes.erb'),
    notify  => Service['network'],
  }
} # define network::suse_routes
