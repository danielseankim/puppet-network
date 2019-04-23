# == Definition: network::bond::vlan
#
define network::bond::vlan (
  $ensure,
  $bootproto = 'none',
  $ipaddress = undef,
  $netmask = undef,
  $vlanId,
  $gateway = undef,
  $macaddress = '',
  $mtu = undef,
  $ethtool_opts = undef,
  $bonding_opts = 'miimon=100',
  $peerdns = false,
  $ipv6init = false,
  $ipv6address = undef,
  $ipv6gateway = undef,
  $ipv6peerdns = false,
  $dns1 = undef,
  $dns2 = undef,
  $domain = undef,
  $type = "Bond"
) {

  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if ! $vlanId { fail("vlanId must be passed for this resource type!") }
  if $ipaddress and ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  if $ipv6address {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }
  validate_bool($ipv6init)
  validate_bool($ipv6peerdns)

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  $interface = $name
  $already_configured = $name in split($::interfaces, ',')
  $bond_already_configured = split($interface, '\.')[0] in split($::interfaces, ',')
  $bond_interface = split($interface, '\.')[0]

  if !$already_configured {
    if !$bond_already_configured {
      exec { "add modprobe bonding config for ${interface}":
        command => "/bin/echo 'alias ifcfg-${bond_interface} bonding' >> /etc/modprobe.d/bonding.conf",
        unless => "/usr/bin/test -f /etc/modprobe.d/bonding.conf && /bin/grep ifcfg-${bond_interface} /etc/modprobe.d/bonding.conf"
      } ->
      exec { "create bonding module load config for ${interface}":
        command => "/bin/echo 'bonding' >> /etc/modules-load.d/bonding.conf",
        onlyif  => "/usr/bin/test -d /etc/modules-load.d/",
        unless  => "/usr/bin/test -f /etc/modules-load.d/bonding.conf"
      } ->
      exec { "create vlan module load config for ${interface}":
        command => "/bin/echo '8021q' >> /etc/modules-load.d/8021q.conf",
        onlyif  => "/usr/bin/test -d /etc/modules-load.d/",
        unless  => "/usr/bin/test -f /etc/modules-load.d/8021q.conf"
      } ->
      exec { "reload modprobe after ${interface} is added to bonding module config":
        command => '/sbin/modprobe -r bonding; /sbin/modprobe bonding'
      }
    }
    file { "ifcfg-${interface}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
      content => template('network/ifcfg-eth.erb'),
      require => Network::Bond::Static[split($interface, '\.')[0]],
      notify => Service['network']
    }
  }
} # define network::bond::vlan
