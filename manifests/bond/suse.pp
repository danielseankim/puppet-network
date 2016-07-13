define network::bond::suse (
  $ensure,
  $bonding_opts = "",
  $mtu = "",
  $slaves = ""
) {
  $slave_devices = get_slave_devices($slaves)

  # Validate the array
  validate_array($slave_devices)

  include '::network'

  $already_configured = $title in split($::interfaces, ',')
  if !$already_configured {
    file { "ifcfg-${name}":
        ensure  => 'present',
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/sysconfig/network/ifcfg-${name}",
        content => template('network/ifcfg-suse-bond.erb'),
        notify  => Service['network'],
      }
  }
} # define network::bond::suse
