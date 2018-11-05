# Sets up a repository, including autosigning
define reprepro::repo (
  String $architectures,
  Array $codenames,
  Array $components,
  String $description,
  String $dist,
  String $key_id,
  String $label,
  String $origin,
  String $public_key,
  Boolean $folder_per_resource = true,
  Boolean $manage_web_server   = lookup('reprepro::manage_web_server'),
  String $main_folder          = lookup('reprepro::main_folder'),
  String $signing_user         = lookup('reprepro::signing_user'),
  String $www_group            = lookup('reprepro::www_group'),
  String $www_user             = lookup('reprepro::www_user'),
) {
  if $manage_web_server == true {
    file { "/etc/apache2/conf.d/${title}":
      ensure  => directory,
      content => template('reprepro/apache_repo.erb'),
      group   => $www_group,
      owner   => $www_user,
    }
  }
  if $folder_per_resource == true {
    $folders = [
      "${main_folder}/${title}",
      "${main_folder}/${title}/${dist}",
      "${main_folder}/${title}/${dist}/conf"
    ]
    $repofolder = "${main_folder}/${title}/${dist}"
  } else {
    $folders = [
      "${main_folder}/${dist}",
      "${main_folder}/${dist}/conf"
    ]
    $repofolder = "${main_folder}/${dist}"
  }
  file { $folders:
    ensure => directory,
    owner  => $www_user,
    group  => $www_group,
  }
  file { "${repofolder}/incoming":
    ensure => directory,
    owner  => $www_user,
    group  => $www_group,
    mode   => '0775'
  }
  file { "${repofolder}/conf/distributions":
    ensure  => present,
    content => template('reprepro/distributions.erb'),
    group   => $www_group,
    owner   => $www_user,
  }
  file { "${repofolder}/pubkey.gpg":
    ensure  => present,
    content => $public_key,
    group   => $www_group,
    owner   => $www_user,
  }
  cron { "sign incoming packages for ${title}":
    ensure  => present,
    command => "for file in ${repofolder}/incoming/*; do /usr/bin/reprepro -b ${repofolder}/ includedeb ${codename} \$file; done \
    && /bin/chown -R ${www_user}:${www_group} ${repofolder}",
    user    => $signing_user,
    minute  => '*/5',
  }
}
