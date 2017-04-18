# == Definition: network::bond::slave
#
# Creates a bonded slave interface.
#
# === Parameters:
#
#   $macaddress   - required
#   $master       - required
#   $ethtool_opts - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Requires:
#
#   Service['network']
#
# === Sample Usage:
#
#   network::bond::slave { 'eth1':
#     macaddress => $::macaddress_eth1,
#     master     => 'bond0',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::bond::slave (
  $macaddress,
  $master,
  $ethtool_opts = undef,
  $mtu = undef
) {
  # Validate our data
  if ! is_mac_address($macaddress) {
    fail("${macaddress} is not a MAC address.")
  }

  include '::network'

  if is_mac_address($name){
    $interface = map_macaddr_to_interface($name)
    if !$interface {
      fail('Could not find the interface name for the given macaddress...')
    }
  } else {
    $interface = $name
  }

  $already_configured = $master in split($::interfaces, ',')

  if !$already_configured {

    file { "ifcfg-${interface}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
      content => template('network/ifcfg-bond.erb'),
      before  => File["ifcfg-${master}"]
    }
  }

} # define network::bond::slave
