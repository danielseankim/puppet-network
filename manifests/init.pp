# == Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
# === Parameters:
#
# None
#
# === Actions:
#
# Defines the network service so that other resources can notify it to restart.
#
# === Sample Usage:
#
#   include '::network'
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
class network {
  # Only run on RedHat/CentOS and SLES derived systems.
  case $::osfamily {
    'RedHat': { }
    'Suse': {
      case $::operatingsystemrelease {
        /^(11|12)/: { }
        default: {
          fail("This network module only supports SLES 11 and 12 systems. The current machine uses ${$::operatingsystemrelease}")
        }
      }
    }
    default: {
      fail("This network module only supports RedHat and Suse based systems. Current machine OS family is ${$::osfamily}")
    }
  }

  # Disable NetworkManager - otherwise it may cause issues with default gateway and other routing rules
  service { 'NetworkManager':
    ensure     => 'stopped',
    enable     => false
  }

  clean_ifcfg { 'clean_if_configs':
    before => Service['network'],
  }

  # We use a custom service provider defined in this module for rhel/centos7 to eliminate an issue with "orphaned" dhclients
  service { 'network':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    provider   => $::operatingsystemmajrelease ? {
      "7"     => "systemd_network",
      default => undef
    }
  }

  # Validate valid IP address(es) have been assigned; this affects Suse 12 VMs only!
  check_interface { "check_interface":
    operation => "restart_interface",
    require => Service["network"],
  }
} # class network
