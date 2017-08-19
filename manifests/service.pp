# This subclass optionally manages the postfix service.  The name of the managed
# service can be customized if necessary and service management can be entirely
# disabled.
#
# @summary Optionally manages the postfix service by any name.
#
# @example Default; service is managed and always running
#  ---
#  classes:
#    - postfix
#
# @example Disable service management (e.g.:  for containers)
#  ---
#  classes:
#    - postfix
#  postfix::service_managed: false
#
# @example Stop the service
#  ---
#  classes:
#    - postfix
#  postfix::service_ensure: stopped
#
class postfix::service {
  if $postfix::service_managed
    and ! ($postfix::package_ensure in ['absent', 'purged'])
  {
    service { 'postfix':
      ensure    => $postfix::service_ensure,
      name      => $postfix::service_name,
      enable    => $postfix::service_enable,
      subscribe => [ Package['postfix'], ],
    }
  }
}
# vim: syntax=puppet:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
