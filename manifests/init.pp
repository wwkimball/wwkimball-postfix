# Class: postfix
#
# This module fully manages postfix.
#
# @param check_files Similar to config_files, this Hash represents a set of
#  *_checks files that Postfix can be configured to consume for various check
#  operations, like header_checks, body_checks, and such.  Unlike config_files
#  however, these are not key-value configurations.  Instead, these are
#  populated as Arrays of Strings, with each element being a complete check
#  rule.
# @param config_file_attributes Set of attributes to apply to all configuration
#  files that are managed by this module.  These are file resource attributes,
#  per: https://docs.puppet.com/puppet/latest/types/file.html#file-attributes
# @param config_file_path Fully-qualified path to where the Postfix
#  configuration file -- and all config_files -- are stored.
# @param config_files Excluding master.cf (controlled via master_processes) and
#  main.cf (controlled via global_parameters), this is a set of additional
#  configuration files for Postfix.  Such files are typically lookup
#  configurations for external services like MySQL, PostgreSQL, and such.  This
#  Hash has structure:
#  configuration-file-name-relative-to-config_file_path-N:
#    key1: value1
#    keyN: valueN
# @param global_parameters Full content of main.cf as a Hash with structure:
#  key: value
# @param master_processes Full content of master.cf as a Hash with structure:
#  service-name/service-type:
#    command:  command name and its arguments
#    private:  OPTIONAL, y or n
#    unpriv:  OPTIONAL, y or n
#    chroot:  OPTIONAL, y or n
#    wakeup:  OPTIONAL, any positive number; may end with ?
#    maxproc:  OPTIONAL, any positive number
# @param package_ensure Version or state of the postfix package.
# @param package_name Name of the Postfix package to manage.
# @param purge_config_file_path Indicates whether to delete any configuration
#  files that sneak into config_file_path that are not Puppet-managed.
# @param service_enable Indicates whether the managed service should start at
#  boot, when service_managed is enabled.
# @param service_ensure The running state of the managed service, when
#  service_managed is enabled. 
# @param service_managed Indicates whether to manage the postfix service.
# @param service_name Name of the service to manage, when service_managed is
#  enabled.
#
# @see http://www.postfix.org/master.5.html
# @see http://www.postfix.org/postconf.5.html
#
# @example
#  ---
#  classes:
#    - postfix
#
class postfix(
  Hash[String[4], Any]       $config_file_attributes,
  String[3]                  $config_file_path,
  Hash[String[4], Any]       $config_file_path_attributes,
  Hash[
    Pattern[/^[A-Za-z0-9_]+$/],
    Variant[String, Integer]
  ]                          $global_parameters,
  Hash[
    Pattern[/^[a-z]+\/(inet|unix|fifo|pass)$/],
    Struct[{
      command             => String[2],
      Optional['private'] => Enum['y', 'n'],
      Optional['unpriv']  => Enum['y', 'n'],
      Optional['chroot']  => Enum['y', 'n'],
      Optional['wakeup']  => Variant[Pattern[/^(0|[1-9][0-9]*)\??$/], Integer],
      Optional['maxproc'] => Integer,
  }]]                        $master_processes,
  String                     $package_ensure,
  String[2]                  $package_name,
  Boolean                    $purge_config_file_path,
  Boolean                    $service_enable,
  Enum[running, stopped]     $service_ensure,
  Boolean                    $service_managed,
  String[2]                  $service_name,
  Optional[Hash[
    String[2],
    Array[String[2]]
  ]]                         $check_files  = undef,
  Optional[Hash[
    String[2],
    Hash[
      Pattern[/^[A-Za-z0-9_]+$/],
      Any
  ]]]                        $config_files = undef,
) {
  class { '::postfix::package': }
  -> class { '::postfix::config': }
  ~> class { '::postfix::service': }
  -> Class['postfix']
}
# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
