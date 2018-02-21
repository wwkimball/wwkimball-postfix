# This subclass manages all postfix configuration files from master.cf and
# main.cf to all custom, user-created setting and check files.  All of these
# files are kept on the node unless `postfix::package_ensure: purged`.
#
# @summary Manages all postfix configuration and check files.
#
# @example Default configuration; all files are vendor-defaults
#  ---
#  classes:
#    - postfix
#
# @example General config with PCRE header and body checks
#  ---
#  classes:
#    - postfix
#
#  # Set global parameters
#  postfix::global_parameters:
#    myhostname: mail.%{facts.domain}
#    mynetworks: 127.0.0.0/8
#    inet_interfaces: all
#    home_mailbox: Maildir/
#    header_checks: pcre:%{lookup('postfix::config_file_path')}/check_header
#    body_checks: pcre:%{lookup('postfix::config_file_path')}/check_body
#
#  # Define the header and body checks
#  postfix::check_files:
#    check_header:
#      - '/X-SPAM-FLAG: YES/ REJECT  UCE detected.'
#      - '/spam_agent/       REJECT  UCE detected.'
#      - '/spam\.domain/     REJECT  UCE detected.'
#    check_body:
#      - '/spam\.domain/     REJECT  UCE detected.'
#
# @example Use MySQL lookup tables for virtual mail delivery
#  ---
#  classes:
#    - postfix
#
#  # Reusable YAML Values
#  aliases:
#    - &virtual_mail_base_directory /var/spool/virtual-mail
#
#  # Define a reusable Hash alias for shared database parameters
#  postfixLookupDatabase: &postfixLookupDatabase
#    hosts: email-database-server
#    user: email-user-name
#    password: secret-email-password
#    dbname: email-database
#
#  # Define the MySQL lookup maps, merging in the shared database parameters
#  postfix::config_files:
#    lookup_domains.cf:
#      <<: *postfixLookupDatabase
#      query: >
#        SELECT domain FROM domain
#        WHERE domain = '%s' AND backupmx = '0' AND active = '1'
#    lookup_users.cf:
#      <<: *postfixLookupDatabase
#      query: >
#        SELECT maildir FROM mailbox
#        WHERE username = '%s' AND active = '1'
#    lookup_aliases.cf:
#      <<: *postfixLookupDatabase
#      query: >
#        SELECT goto FROM alias
#        WHERE address = '%s' AND active = '1'
#
#  # Set global parameters to enable proxying the DB connections and define some
#  # MySQL lookup maps.  Also tell Postfix where and as whom to deliver the
#  # virtual mail.
#  postfix::global_parameters:
#    proxy_read_maps: >
#      $virtual_mailbox_domains,
#      $virtual_mailbox_maps,
#      $virtual_alias_maps
#    virtual_mailbox_domains: proxy:mysql:%{lookup('postfix::config_file_path')}/lookup_domains.cf
#    virtual_mailbox_maps: proxy:mysql:%{lookup('postfix::config_file_path')}/lookup_users.cf
#    virtual_alias_maps: proxy:mysql:%{lookup('postfix::config_file_path')}/lookup_aliases.cf
#    virtual_mailbox_base: *virtual_mail_base_directory
#    virtual_gid_maps: static:5000
#    virtual_uid_maps: static:5000
#
#  # Permit this module to manage the virtual mail delivery base directory
#  postfix::virtual_delivery_dir: *virtual_mail_base_directory
#  postfix::virtual_delivery_dir_attributes:
#    owner: 5000
#    group: 5000
#    mode: '0750'
#
# @example Add Let's Encrypt certificates
#  ---
#  classes:
#    - postfix
#    - letsencrypt  # Not documented, here
#
#  # Define reusable value aliases for the certificate files
#  aliases:
#    - &cert_file /etc/letsencrypt/live/mail.%{facts.domain}/fullchain.pem
#    - &key_file /etc/letsencrypt/live/mail.%{facts.domain}/privkey.pem
#
#  # Set global parameters to use the certificate files for SMTP/D
#  postfix::global_parameters:
#    myhostname: mail.%{facts.domain}
#    smtp_tls_cert_file: *cert_file
#    smtp_tls_key_file: *key_file
#    smtpd_tls_cert_file: *cert_file
#    smtpd_tls_key_file: *key_file
#
class postfix::config {
  if 'purged' == $postfix::package_ensure {
    # Note:  never destroy the $virtual_delivery_dir to avoid destroying mail.
    file {
      default:
        ensure => absent,
        force  => true,
      ;

      $postfix::config_file_path:;
      $postfix::spool_dir_base:;
    }
  } else {
    $knockout_prefix = $postfix::config_hash_key_knockout_prefix

    # Ensure the configuration directory exists
    $purge_recurse_limit = $postfix::purge_config_file_path ? {
      true    => 1,
      default => undef,
    }
    file { $postfix::config_file_path:
      ensure       => directory,
      purge        => $postfix::purge_config_file_path,
      recurse      => $postfix::purge_config_file_path,
      recurselimit => $purge_recurse_limit,
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
      file { "${postfix::config_file_path}/${file}":
        ensure  => file,
        content => template("${module_name}/config-file.erb"),
        *       => $postfix::config_file_attributes,
      }
    }
    pick($postfix::check_files, {}).each |
      String $file,
      Array[String] $rules,
    | {
      file { "${postfix::config_file_path}/${file}":
        ensure  => file,
        content => template("${module_name}/check-file.erb"),
        *       => $postfix::config_file_attributes,
      }
    }

    # Manage the spool directory and its subordinates
    file { $postfix::spool_dir_base:
      ensure => directory,
      *      => $postfix::spool_dir_base_attributes,
    }
    pick($postfix::spool_subdir_attributes, {}).each |
      String $subdir,
      Hash   $attrs,
    | {
      file { "${postfix::spool_dir_base}/${subdir}":
        ensure => directory,
        *      => $attrs,
      }
    }

    # Manage the optional $virtual_delivery_dir, if used.
    if undef != $postfix::virtual_delivery_dir {
      # No default attributes for this directory will be assumed because it is
      # critical that Postfix be able to write to this directory tree.
      if undef == $postfix::virtual_delivery_dir_attributes {
        fail("When setting postfix::virtual_delivery_dir, you must also provide attributes as a Hash to postfix::virtual_delivery_dir_attributes.")
      }

      file { $postfix::virtual_delivery_dir:
        ensure => directory,
        *      => $postfix::virtual_delivery_dir_attributes,
      }
    }
  }
}
# vim: syntax=puppet:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
