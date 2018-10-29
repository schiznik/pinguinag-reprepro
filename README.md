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

You have to create a GPG key without a passphrase:

```
gpg --gen-key
```

Where you store it is up to you but it has to be available for the www_user

## Usage

```
include reprepro

reprepro::repo { 'my-first-repository':
  architectures => 'amd64',
  codename      => 'stretch',
  components    => ['main', 'sources'],
  description   => 'my first repo',
  dist          => 'debian',
  key_id        => 'ABCDEF',
  label         => 'apt.example.com',
  origin        => 'apt.example.com'
  public_key    => 'AAAAAAAAAAAAAABBBBBBBBBBBBBBCCCCCCCCCCCC...'
}
```
