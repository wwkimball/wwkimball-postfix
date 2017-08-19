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
# @example Use MySQL lookup tables
#  ---
#  classes:
#    - postfix
#
#  # Define a reusable Hash alias for shared database parameters
#  postfixLookupDatabase: &postfixLookupDatabase
#    hosts: email-database-server
#    user: email-user-name
#    password: secret-email-password
#    dbname: email-database
#
#  # Set global parameters to enable proxying the DB connections and define some
#  # MySQL lookup maps.
#  postfix::global_parameters:
#    proxy_read_maps: >
#      $virtual_mailbox_domains,
#      $virtual_mailbox_maps,
#      $virtual_alias_maps
#    virtual_mailbox_domains: proxy:mysql:%{lookup('postfix::config_file_path')}/lookup_domains.cf
#    virtual_mailbox_maps: proxy:mysql:%{lookup('postfix::config_file_path')}/lookup_users.cf
#    virtual_alias_maps: proxy:mysql:%{lookup('postfix::config_file_path')}/lookup_aliases.cf
#
#  # Define the MySQL lookup maps, merging in the shared database parameters
#  postfix::config_files:
#    lookup_domains.cf:
#      <<: *postfixLookupDatabase
#      table: domain
#      select_field: domain
#      where_field: domain
#      additional_conditions: and backupmx = '0' and active = '1'
#    lookup_users.cf:
#      <<: *postfixLookupDatabase
#      table: mailbox
#      select_field: maildir
#      where_field: username
#      additional_conditions: and active = '1'
#      result_format: '%s'
#    lookup_aliases.cf:
#      <<: *postfixLookupDatabase
#      table: alias
#      select_field: goto
#      where_field: address
#      additional_conditions: and active = '1'
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
    file { $postfix::config_file_path:
      ensure => absent,
      force  => true,
    }
  } else {
    $knockout_prefix = $postfix::config_hash_key_knockout_prefix

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
  }
}
# vim: syntax=puppet:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:ai
