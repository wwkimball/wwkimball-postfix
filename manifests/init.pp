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
#  per this module's hiera.yaml.  <strong>NOTE</strong>:  When using Postfix 3+,
#  you must set an appropriate `compatibility_level`.
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
# @param plugin_packages Hash describing additional postfix packages to install.
#  This is necessary for Postfix 3+ where features like MySQL or PgSQL are
#  enabled by which of these additional plugin_packages are installed along with
#  Postfix.  Such plugin packages are typically named like "postfix-mysql" or
#  "postfix3-mysql", depending on your upstream repositories' naming
#  conventions.  This Hash has structure:<br>
#  &nbsp; /^postfix.*-.+$/:<br>
#  &nbsp;&nbsp;&nbsp; ensure:  OPTIONAL, https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-ensure<br>
#  &nbsp;&nbsp;&nbsp; provider:  OPTIONAL, https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-provider<br>
#  &nbsp;&nbsp;&nbsp; source:  OPTIONAL, https://puppet.com/docs/puppet/latest/types/package.html#package-attribute-source<br>
#  &nbsp; ...<br>
#  By default, no plugin packages are installed; you must indicate all Postfix
#  plugins that you wish to install.
# @param purge_config_file_path Indicates whether to ensure that only Puppet-
#  managed configuration files exist in `config_file_path`.  Default is found in
#  the data directory of this module's source and is applied per this module's
#  hiera.yaml.  <strong>WARNING</strong>:  Set this to `false` for Postfix 3+.
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
# @example Minimally install Postfix 3 with PCRE and MySQL support
#  # This fictional upstream repository uses the name 'postfix' for Postfix
#  # version 2.x and a different name, 'postfix3', for Postfix 3 packages.  Both
#  # use the same service name, 'postfix' (the default).
#  ---
#  classes:
#    - postfix
#
#  postfix::package_name: postfix3
#
#  # You MUST disable purge_config_file_path for Postfix 3, for now.  If you
#  # fail to do so, some important -- unmanaged -- configuration files will be
#  # destroyed.
#  postfix::purge_config_file_path: false
#
#  # Add Postfix plugin support for PCRE and MySQL
#  postfix::plugin_packages:
#    postfix3-pcre: {}
#    postfix3-mysql: {}
#
class postfix(
  Hash[String[4], Any]           $config_file_attributes,
  String[3]                      $config_file_path,
  Hash[String[4], Any]           $config_file_path_attributes,
  Pattern[/^-+$/]                $config_hash_key_knockout_prefix,
  Hash[
    Pattern[/^-*[A-Za-z0-9_]+$/],
    Variant[String, Integer]
  ]                              $global_parameters,
  Hash[
    Pattern[/^-*[a-z]+\/(inet|unix|fifo|pass)$/],
    Struct[{
      command             => String[2],
      Optional['private'] => Enum['y', 'n'],
      Optional['unpriv']  => Enum['y', 'n'],
      Optional['chroot']  => Enum['y', 'n'],
      Optional['wakeup']  => Variant[Pattern[/^(0|[1-9][0-9]*)\??$/], Integer],
      Optional['maxproc'] => Integer,
  }]]                            $master_processes,
  String                         $package_ensure,
  String[2]                      $package_name,
  Boolean                        $purge_config_file_path,
  Boolean                        $service_enable,
  Enum['running', 'stopped']     $service_ensure,
  Boolean                        $service_managed,
  String[2]                      $service_name,
  Optional[Hash[
    String[2],
    Array[String[2]]
  ]]                             $check_files                     = undef,
  Optional[Hash[
    String[2],
    Hash[
      Pattern[/^-*[A-Za-z0-9_]+$/],
      Any
  ]]]                            $config_files                    = undef,
  Optional[Hash[
    Pattern[/^postfix.*-.+$/],
    Struct[{
      Optional['ensure']   => String[1],
      Optional['provider'] => String[1],
      Optional['source']   => String[1],
  }]]]                           $plugin_packages                 = undef,
  Optional[Stdlib::Absolutepath] $virtual_delivery_dir            = undef,
  Optional[Hash[String[1], Any]] $virtual_delivery_dir_attributes = undef,
) {
  class { '::postfix::package': }
  -> class { '::postfix::config': }
  ~> class { '::postfix::service': }
  -> Class['postfix']
}
# vim: syntax=puppet:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
