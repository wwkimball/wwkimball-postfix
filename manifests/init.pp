# This module fully manages postfix.  It can install,  uninstall, and version-
# pin postifx; configure or delete every vendor and custom configuration file;
# and optionally manage the postfix service.
#
# @summary Fully manages postfix.
#
# @param check_files Set of configuration files that serve as local lookup
#  tables for postfix *_check rules (e.g.: header_checks, body_checks, and
#  such).  The structure of this Hash is as follows:<br>
#  &nbsp; FILENAME:<br>
#  &nbsp;&nbsp;&nbsp; - CHECK_RULE<br>
#  &nbsp;&nbsp;&nbsp; - ...<br>
#  &nbsp; ...<br>
#  Default is found in the data directory of this module's source and is applied
#  per this module's hiera.yaml.
# @param config_file_attributes Set of attributes to apply to all configuration
#  files that are managed by this module.  These are file resource attributes,
#  per: https://docs.puppet.com/puppet/latest/types/file.html#file-attributes
#  Default is found in the data directory of this module's source and is applied
#  per this module's hiera.yaml.
# @param config_file_path Fully-qualified path to where the Postfix
#  configuration files are stored.  Default is found in the data directory of
#  this module's source and is applied per this module's hiera.yaml.
# @param config_file_path_attributes Puppet attributes applied to
#  `config_file_path`.  Default is found in the data directory of this module's
#  source and is applied per this module's hiera.yaml.  Default is found in the
#  data directory of this module's source and is applied per this module's
#  hiera.yaml.
# @param config_files Excluding master.cf (controlled via master_processes) and
#  main.cf (controlled via global_parameters), this is a set of additional
#  configuration files for Postfix.  Such files are typically lookup
#  configurations for external services like MySQL, PostgreSQL, and such.  This
#  Hash has structure:<br>
#  &nbsp; FILENAME:<br>
#  &nbsp;&nbsp;&nbsp; KEY: VALUE<br>
#  &nbsp;&nbsp;&nbsp; ...<br>
#  &nbsp; ...<br>
#  Default is found in the data directory of this module's source and is applied
#  per this module's hiera.yaml.
# @param config_hash_key_knockout_prefix String of `-` characters which, when
#  present as a prefix to any supporting Hash key, will cause that entire key
#  and its value to be removed from the resulting rendered configuration file.
#  This is limited to one or more hyphen (`-`) characters because the matching
#  patterns for the keys users would likely must assume a pre-known value for
#  this parameter and one or more hyphens seems most reasonable.  Default is
#  found in the data directory of this module's source and is applied per this
#  module's hiera.yaml.
# @param global_parameters Full content of main.cf as a Hash with structure:<br>
#  &nbsp; KEY: VALUE<br>
#  &nbsp; ...<br>
#  Default is found in the data directory of this module's source and is applied
#  per this module's hiera.yaml.
# @param master_processes Full content of master.cf as a Hash with structure:<br>
#  &nbsp; service-name/service-type:<br>
#  &nbsp;&nbsp;&nbsp; command:  command name and its arguments<br>
#  &nbsp;&nbsp;&nbsp; private:  OPTIONAL, y or n<br>
#  &nbsp;&nbsp;&nbsp; unpriv:  OPTIONAL, y or n<br>
#  &nbsp;&nbsp;&nbsp; chroot:  OPTIONAL, y or n<br>
#  &nbsp;&nbsp;&nbsp; wakeup:  OPTIONAL, any positive number; may end with ?<br>
#  &nbsp;&nbsp;&nbsp; maxproc:  OPTIONAL, any positive number<br>
#  &nbsp; ...<br>
#  Default is found in the data directory of this module's source and is applied
#  per this module's hiera.yaml.
# @param package_ensure Precise version number of the postfix package to install
#  (and lock-in, blocking up/downgrades) or any Puppet token value to more
#  generically control the installed package version or to uninstall postfix,
#  optionally purging all postfix configuration files.  By default, this package
#  is merely installed without any up/downgrade management.
# @param package_name Name of the primary postfix package to manage, per your
#  operating system and distribution.  Default is found in the data directory of
#  this module's source and is applied per this module's hiera.yaml.
# @param purge_config_file_path Indicates whether to ensure that only Puppet-
#  managed configuration files exist in `config_file_path`.  Default is found in
#  the data directory of this module's source and is applied per this module's
#  hiera.yaml.
# @param service_enable Indicates whether the postfix service will self-start
#  on node restart.  Default is found in the data directory of this module's
#  source and is applied per this module's hiera.yaml.
# @param service_ensure One of running (postfix service is kept on) or stopped
#  (postfix service is kept off).  Default is found in the data directory of
#  this module's source and is applied per this module's hiera.yaml.
# @param service_managed Indicates whether Puppet will manage the postfix
#  service.  All other service_* parameters are ignored when this is disabled.
#  Default is found in the data directory of this module's source and is applied
#  per this module's hiera.yaml.
# @param service_name Name of the service to manage when `service_managed` is
#  enabled.  Default is found in the data directory of this module's source and
#  is applied per this module's hiera.yaml.
#
# @see http://www.postfix.org/master.5.html
# @see http://www.postfix.org/postconf.5.html
#
# @example Minimum configuration, sufficient for vendor-specified defaults
#  ---
#  classes:
#    - postfix
#
class postfix(
  Hash[String[4], Any]       $config_file_attributes,
  String[3]                  $config_file_path,
  Hash[String[4], Any]       $config_file_path_attributes,
  Pattern[/^-+$/]            $config_hash_key_knockout_prefix,
  Hash[
    Pattern[/^-*[A-Za-z0-9_]+$/],
    Variant[String, Integer]
  ]                          $global_parameters,
  Hash[
    Pattern[/^-*[a-z]+\/(inet|unix|fifo|pass)$/],
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
  Enum['running', 'stopped'] $service_ensure,
  Boolean                    $service_managed,
  String[2]                  $service_name,
  Optional[Hash[
    String[2],
    Array[String[2]]
  ]]                         $check_files  = undef,
  Optional[Hash[
    String[2],
    Hash[
      Pattern[/^-*[A-Za-z0-9_]+$/],
      Any
  ]]]                        $config_files = undef,
) {
  class { '::postfix::package': }
  -> class { '::postfix::config': }
  ~> class { '::postfix::service': }
  -> Class['postfix']
}
# vim: syntax=puppet:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
