define network::if::vlan (
  $ensure,
  $vlanId          = undef,
  $ipaddress       = undef,
  $netmask         = undef,
  $macaddress      = undef,
  $gateway         = undef,
  $bootproto       = 'none',
  $userctl         = false,
  $mtu             = undef,
  $ethtool_opts    = undef,
  $peerdns         = false,
  $ipv6peerdns     = false,
  $dns1            = undef,
  $dns2            = undef,
  $domain          = undef,
  $linkdelay       = undef,
  $scope           = undef,
) {
# Validate data
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if $ipaddress {
    if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  }
  if $ipv6address {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }

  if is_mac_address($name){
    $interface = map_macaddr_to_interface($name)
    if !$interface {
      fail('Could not find the interface name for the given macaddress...')
    }
  } else {
    $interface = $name
  }

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  $num_configured_interfaces = count_configured_interfaces($name)
  $ifcfg_filepath = ifcfg_filepath($::osfamily)
  if $num_configured_interfaces < 2 {
    file { "ifcfg-${interface}.${vlanId}}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "${ifcfg_filepath}ifcfg-${interface}.${vlanId}",
      content => template('network/ifcfg-eth.erb'),
    }
  }
} # define network::if::vlan