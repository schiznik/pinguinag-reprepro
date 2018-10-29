class reprepro (
  Boolean $manage_web_server,
  String $main_folder,
  String $www_group,
  String $www_user,
  String $fqdn = $facts['networking']['hostname'],
) {
  package { 'reprepro':
    ensure => installed,
  }

  file { $main_folder:
    ensure => directory,
    owner  => $www_user,
    group  => $www_group,
  }

  if $manage_web_server == true {
    include apache

    apache::vhost { $fqdn:
      port          => '80',
      docroot       => $main_folder,
      docroot_owner => $www_user,
      docroot_group => $www_group,
    }
  }
}
