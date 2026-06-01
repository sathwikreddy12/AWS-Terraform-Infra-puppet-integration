# when you write "include base", Puppet looks for base/manifests/init.pp

class base {
  # ── PULL VALUES FROM HIERA ───────────────────────────────


  $timezone = lookup('base::timezone')


  # ── PACKAGES every server needs ──────────────────────────

  $base_packages = [
    'vim',
    'curl',
    'wget',
    'git',
    'htop',
    'net-tools',
  ]

  package { $base_packages:
    ensure => installed,
    # passing a list to package resource
    # Puppet installs each one
    # if already installed → does nothing (idempotent)
  }

  # ── TIMEZONE ─────────────────────────────────────────────

  file { '/etc/localtime':
    ensure => link,
    target => "/usr/share/zoneinfo/${timezone}",
    # symbolic link → sets timezone to IST
    # works on any Linux server anywhere
  }

  # ── DISABLE ROOT SSH LOGIN ───────────────────────────────
  # security hardening — nobody should SSH as root

  file_line { 'disable_root_ssh':
    path  => '/etc/ssh/sshd_config',
    line  => 'PermitRootLogin no',
    match => '^PermitRootLogin',
    # file_line resource:
    # finds the line matching the regex
    # replaces it with the line above
    # if not found → adds it
    notify => Service['sshd'],
    # when this file changes → restart sshd
  }

  # ── SSHD SERVICE ─────────────────────────────────────────

  service { 'sshd':
    ensure => running,
    enable => true,
    # ensure running  = start it if not running
    # enable true     = start automatically on server reboot
  }
}
