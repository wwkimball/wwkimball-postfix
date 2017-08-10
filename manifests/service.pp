# Class: postfix::service
#
# This subclass manages the postfix service.
#
# @example
#  ---
#  classes:
#    - postfix
#  postfix::service_ensure: running
#  postfix::service_enable: true
#  postfix::service_managed: true
#
class postfix::service {
  if $postfix::service_managed {
    service { 'postfix':
      ensure    => $postfix::service_ensure,
      name      => $postfix::service_name,
      enable    => $postfix::service_enable,
      subscribe => [ Package['postfix'], ],
    }
  }
}
# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
