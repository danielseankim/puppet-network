# == Definition: network::route
#
# Configures /etc/sysconfig/networking-scripts/route-$name.
#
# === Parameters:
#
#   $ipaddress - required
#   $netmask   - required
#   $gateway   - required
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/route-$name.
#
# === Requires:
#
#   File["ifcfg-$name"]
#   Service['network']
#
# === Sample Usage:
#
#   network::route { 'eth0':
#     ipaddress => [ '192.168.17.0', ],
#     netmask   => [ '255.255.255.0', ],
#     cidr   => [ '24', ],
#     gateway   => [ '192.168.17.250', ],
#   }
#
#   network::route { 'bond2':
#     ipaddress => [ '192.168.2.0', '10.0.0.0', ],
#     netmask   => [ '255.255.255.0', '255.0.0.0', ],
#     cidr   => [ '24', '16' ],
#     gateway   => [ '192.168.1.1', '10.0.0.1', ],
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
define network::route (
  $ipaddress,
  $netmask,
  $cidr,
  $gateway
) {
  # Validate our arrays
  validate_array($ipaddress)
  validate_array($netmask)
  validate_array($cidr)
  validate_array($gateway)

  include '::network'

  if is_mac_address($name) {
    $interface = map_macaddr_to_interface($name)
    if !$interface {
      fail('Could not find the interface name for the given macaddress...')
    }
  } else {
    $interface = $name
  }

  file { "route-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/route-${interface}",
    content => template('network/route-eth.erb'),
    notify  => Service['network'],
  }

  $interface_escaped = shell_escape($interface)

  $ipaddress.each |Integer $index, String $ipaddr| {
    $ipaddr_escaped = shell_escape($ipaddr)
    $gateway_escaped = shell_escape($gateway[$index])
    $route_escaped = shell_escape("$ipaddr/${cidr[$index]}")

    exec { "Run cmd to add ${interface} static route for ${ipaddr}":
      command => "/usr/sbin/ip route add ${route_escaped} via ${gateway_escaped} dev ${interface_escaped}",
      onlyif => "/usr/bin/test -z `/usr/sbin/ip route | grep ${route_escaped}`"
    }
  }

} # define network::route
