# Ships logs and metrics to AWS CloudWatch

class monitoring {

  # ── PULL VALUES FROM HIERA ───────────────────────────────

  $log_group         = lookup('monitoring::log_group')
  $metrics_namespace = lookup('monitoring::metrics_namespace')

  # ── INSTALL CLOUDWATCH AGENT ─────────────────────────────

  package { 'amazon-cloudwatch-agent':
    ensure   => installed,
    provider => 'rpm',
  }

  # ── CLOUDWATCH CONFIG FILE ───────────────────────────────

  file { '/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json':
    ensure  => present,
    content => template('monitoring/cloudwatch.json.erb'),
    require => Package['amazon-cloudwatch-agent'],
    notify  => Service['amazon-cloudwatch-agent'],
  }

  # ── START CLOUDWATCH AGENT ───────────────────────────────

  service { 'amazon-cloudwatch-agent':
    ensure  => running,
    enable  => true,
    require => Package['amazon-cloudwatch-agent'],
  }
}
