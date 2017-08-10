# Class: postfix::package
#
# This subclass manages the postfix package.
#
# @example
#  ---
#  classes:
#    - postfix
#  postfix::package_ensure: latest
#
class postfix::package {
  package { 'postfix':
    name   => $postfix::package_name,
    ensure => $postfix::package_ensure,
  }
}
# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
