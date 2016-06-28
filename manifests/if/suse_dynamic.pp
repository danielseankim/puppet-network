# == Definition: network::if::suse_dynamic
#
# === Authors:
#
# Daniel Kim <kdaniel@vmware.com>
#
# === Copyright:
#
# Copyright (C) 2016 Dell, Inc.
#
define network::if::suse_dynamic (
  $ensure,
  $macaddress      = undef,
  $bootproto       = 'dhcp',
  $ipaddress       = '',
  $netmask         = '',
  $gateway         = '',
  $userctl         = false,
  $mtu             = undef,
  $dhcp_hostname   = undef,
  $ethtool_opts    = undef,
  $peerdns         = false,
  $isethernet      = true,
  $type            = "",
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  if (! is_mac_address($macaddress)) and (type($name) != "integer") {
  # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } else {
    $macaddy = $macaddress
  }
  # Validate booleans
  validate_bool($userctl)
  validate_bool($peerdns)

  # ASM: For baremetal server, the name is the mac address of the port or partition.
  #      For VM deployment, the name is always the sequence of the network interface.
  if (type($name) == "integer") {
    $interface = get_seq_interface($name)
  } elsif is_mac_address($name) {
    $interface = map_macaddr_to_interface($name)
    if !$interface {
      fail('Could not find the interface name for the given macaddress...')
    }
  } else {
    $interface = $name
  }

  include '::network'

  file { "/etc/sysconfig/network/ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network/ifcfg-${interface}",
    content => template('network/ifcfg-suse-eth.erb'),
    notify => Service['network'],
  }
} # define network::if::suse_dynamic
