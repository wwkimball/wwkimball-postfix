# Class: postfix::config
#
# This subclass manages postfix configuration files.
#
# @example
#
class postfix::config {
  # Ensure the configuration directory exists
  file { $postfix::config_file_path:
    ensure       => directory,
    purge        => $postfix::purge_config_file_path,
    recurse      => $postfix::purge_config_file_path,
    recurselimit => 1,
    *            => $postfix::config_file_path_attributes,
  }

  # Manage master.cf and main.cf
  file {
    default:
      ensure => file,
      *      => $postfix::config_file_attributes,;

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
        *      => $postfix::config_file_attributes,;
  
      "${postfix::config_file_path}/${file}":
        content => template("${module_name}/config-file.erb"),;
    }
  }
  pick($postfix::check_files, {}).each | String $file, Array[String] $rules, | {
    file {
      default:
        ensure => file,
        *      => $postfix::config_file_attributes,;
  
      "${postfix::config_file_path}/${file}":
        content => template("${module_name}/check-file.erb"),;
    }
  }
}
# vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
