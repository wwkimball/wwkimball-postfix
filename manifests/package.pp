# This subclass manages the postfix package.
#
# @summary Manages the postfix package.
#
# @example Default; postfix is present but not updated
#  ---
#  classes:
#    - postfix
#
# @example Keep postfix up-to-date
#  ---
#  classes:
#    - postfix
#  postfix::package_ensure: latest
#
# @example Uninstall everything postfix-related but retain its configuration
#  ---
#  classes:
#    - postfix
#  postfix::package_ensure: absent
#
# @example Uninstall everything postfix-related and destroy its configuration
#  ---
#  classes:
#    - postfix
#  postfix::package_ensure: purged
#
class postfix::package {
  $default_plugin_attributes = {
    ensure  => present,
    require => Package['postfix'],
    tag     => [ 'postfix-plugin', ],
  }

  package { 'postfix':
    ensure => $postfix::package_ensure,
    name   => $postfix::package_name,
  }

  pick($postfix::plugin_packages, {}).each | String $name, Hash $attrs | {
    if $postfix::package_ensure in ['absent', 'purged'] {
      package { $name:
        ensure => $postfix::package_ensure,
        before => [ Package['postfix'], ],
      }
    } else {
      package {
        default: *=> $default_plugin_attributes,;
        $name:   *=> $attrs,;
      }
    }
  }
}
# vim: syntax=puppet:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
