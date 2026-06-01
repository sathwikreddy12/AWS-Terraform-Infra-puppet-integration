# Applied to app servers only

class webserver {

  # ── INSTALL NGINX ────────────────────────────────────────

  package { 'nginx':
    ensure => installed,
  }

  # ── DEPLOY NGINX CONFIG FROM TEMPLATE ───────────────────

  file { '/etc/nginx/nginx.conf':
    ensure  => present,
    content => template('webserver/nginx.conf.erb'),
    # template() function reads the .erb file
    # replaces variables with real values from hiera
    # then writes the result to /etc/nginx/nginx.conf
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx'],
    # nginx.conf needs nginx installed first
    notify  => Service['nginx'],
    # when config changes → restart nginx automatically
  }

  # ── START AND ENABLE NGINX ───────────────────────────────

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }

  # ── APP DIRECTORY ────────────────────────────────────────

  file { '/var/www/app':
    ensure => directory,
    owner  => 'nginx',
    group  => 'nginx',
    mode   => '0755',
  }
}
