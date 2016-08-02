# Cleans up the PXE network by disabling the onboot
define network::pxe_cleanup (
  $ensure,
  $bootproto       = "dhcp",
  $onboot          = "no",
  $ipaddress       = "",
  $netmask         = "",
  $gateway         = "",
) {
  $states = [ '^clean$', '^ignore$' ]
  validate_re($ensure, $states, '$ensure must be either "clean" or "ignore".')

  if is_mac_address($name) {
    $interface = map_macaddr_to_interface($name)
    if !$interface {
      fail('Could not find the interface name for the given macaddress...')
    }
    $macaddress = $name
  } else {
    fail('Resource name for network::pxe_cleanup must be the MAC address of the target port/partition!')
  }

  $ifcfg_filepath = ifcfg_filepath($::osfamily)

  exec { "ifdown ${interface}":
    command => "ifdown ${interface}",
    path    => ['/usr/bin', '/usr/sbin', '/sbin'],
  }->
  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "${ifcfg_filepath}/ifcfg-${interface}",
    content => template("network/ifcfg-eth.erb"),
    notify => Service['network']
  }
} # define network::pxe_cleanup
