# Sets the resolv.conf for DNS config
define network::resolv (
  $ensure,
  $primary_dns = undef,
  $secondary_dns = undef,
  $domain = undef,
) {
  file { "/etc/resolv.conf":
    ensure  => "${ensure}",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/resolv.conf",
    content => template("network/resolv.erb")
  }
} # define network::resolv
