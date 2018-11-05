#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with reprepro](#setup)
    * [What reprepro affects](#what-reprepro-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)

## Description

Creates repos using reprepro. Automatically signs packages dropped into incoming folder.

Follows: https://wiki.debian.org/DebianRepository/SetupWithReprepro

## Setup

### What reprepro affects

If manage_web_server => true:

* places one config file in /etc/apache2/conf.d/ per repo
* creates main config file in /etc/apache2/sites-enabled/
* creates cronjob signing everything in the incoming folder every 5 minutes this uses flock so you can cluster multiple servers together

### Setup Requirements

You have to be in posession of a GPG key without passphrase:

```
gpg --gen-key
```

This key has to be installed for a user on the system. Example shown below.

## Usage
Reprepro classes and resources below show all available parameters.

Example including automatic installation of GPG key.

```
$key_id           = 'ABCDEF12345'
$private_key_path = '/root/priv.gpg'
$public_key_path  = '/root/pub.pub'

file { $public_key_path:
  ensure => present,
  source => ...,
}
file { $private_key_path:
  ensure => present,
  source => ...,
}
-> exec { 'install gpg key':
  command => "/usr/bin/gpg --import ${private_key_path}",
  unless  => "/usr/bin/gpg --list-keys | grep -q ${key_id}"
}

class { 'reprepro':
  manage_web_server => true,
  main_folder       => '/var/www/reprepro',
  www_group         => 'www-data',
  www_user          => 'www-data',
  fqdn              => $facts['networking']['hostname']
}

reprepro::repo { 'my-first-repository':
  architectures       => 'amd64',
  codenames           => ['stretch', 'sid']
  components          => ['main', 'sources'],
  description         => 'my first repo',
  dist                => 'debian',
  folder_per_resource => true,
  key_id              => $key_id,
  label               => 'apt.example.com',
  origin              => 'apt.example.com',
  public_key          => file('.../pub.gpg'),
  signing_user        => root, # this user needs the gpg key
  manage_web_server   => true,
  main_folder         => '/var/www/reprepro',
  www_group           => 'www-data',
  www_user            => 'www-data'
}
```

This creates a folder structure like this:
${main_folder}/${title}/${dist}

By setting folder_per_resource to false, it will instead create this:
${main_folder}/${dist}

## Breaking changes:

1.1.0:

codename is now codenameS, and an array.
