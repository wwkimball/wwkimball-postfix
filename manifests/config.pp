# Class: postfix::config
#
# This subclass manages postfix configuration files.
#
# @example
#
class postfix::config {
  # Ensure the configuration directory exists
  file { $postfix::config_file_path:
    ensure => directory,
    purge  => $postfix::purge_config_file_path,
    *      => $postfix::config_file_path_attributes,
  }

  # Manage master.cf and main.cf
  file {
    default:
      ensure => file,
      *      => $postfix::config_file_defaults,;

    "${postfix::config_file_path}/master.cf":
      content => template("${module_name}/master-processes.erb"),;

    "${postfix::config_file_path}/main.cf":
      content => template("${module_name}/global-parameters.erb"),;
  }

  # Manage all auxilliary configuration files
  pick($postfix::config_files, {}).each | String $file, Hash $config, | {
    file {
      default:
        ensure => file,
        *      => $postfix::config_file_defaults,;
  
      "${postfix::config_file_path}/${file}":
        content => template("${module_name}/config-file.erb"),;
    }
  }
}
# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
