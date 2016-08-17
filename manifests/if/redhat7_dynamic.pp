# == Definition: network::if::redhat7_dynamic
#
# Creates a normal interface with dynamic IP information.
#
# === Parameters:
#
#   $ensure          - required - up|down
#   $macaddress      - optional - defaults to macaddress_$title
#   $bootproto       - optional - defaults to "dhcp"
#   $userctl         - optional - defaults to false
#   $mtu             - optional
#   $dhcp_hostname   - optional
#   $ethtool_opts    - optional
#   $peerdns         - optional
#   $linkdelay       - optional
#   $check_link_down - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::redhat7_dynamic { '11:11:11:11:11:11':
#     ensure     => 'up',
#     macaddress => $::macaddress_eth2,
#   }
#
#   network::if::redhat7_dynamic { 'eth3':
#     ensure     => 'up',
#     macaddress => 'fe:fe:fe:fe:fe:fe',
#     bootproto  => 'bootp',
#   }
#
define network::if::redhat7_dynamic (
  $ensure,
  $macaddress      = undef,
  $bootproto       = 'dhcp',
  $userctl         = false,
  $mtu             = undef,
  $dhcp_hostname   = undef,
  $ethtool_opts    = undef,
  $peerdns         = false,
  $linkdelay       = undef,
  $check_link_down = false
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if (! is_mac_address($macaddress)) and (type($name) != "integer") {
  # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } else {
    $macaddy = $macaddress
  }

  if (type($name) == "integer") {
    $interface = $name
  } elsif is_mac_address($name) {
    $interface = map_macaddr_to_interface($name)
    if !$interface {
      fail('Could not find the interface name for the given macaddress...')
    }
  } else {
    $interface = $name
  }

  # Validate booleans
  validate_bool($userctl)
  validate_bool($peerdns)

  network_if_base { $interface:
    ensure          => $ensure,
    ipaddress       => '',
    netmask         => '',
    gateway         => '',
    macaddress      => $macaddy,
    bootproto       => $bootproto,
    userctl         => $userctl,
    mtu             => $mtu,
    dhcp_hostname   => $dhcp_hostname,
    ethtool_opts    => $ethtool_opts,
    peerdns         => $peerdns,
    linkdelay       => $linkdelay,
    check_link_down => $check_link_down,
  }
} # define network::if::dynamic

