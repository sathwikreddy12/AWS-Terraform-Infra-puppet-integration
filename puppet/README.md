# Puppet Configuration Management

Configuration management layer built on top of the [AWS Terraform infrastructure](../README.md).
Terraform provisions the servers — Puppet configures them.

---

## How it fits into the project
Terraform              →    Puppet
──────────────────          ──────────────────────────────
Creates EC2 servers    →    Installs packages on them
Creates VPC/subnets    →    Configures nginx, sshd
Creates RDS/S3         →    Ships logs to CloudWatch
→    Enforces config on every run

---

## Structure
puppet/
├── hiera/
│   ├── hiera.yaml          # tells Puppet where to look for data and in what order
│   ├── common.yaml         # default values for all servers
│   └── nodes/
│       ├── appserver.yaml  # overrides for app servers
│       └── bastion.yaml    # overrides for bastion host
├── manifests/
│   └── site.pp             # node classification — which server gets which modules
└── modules/
├── base/               # applied to every server
├── monitoring/         # CloudWatch agent — logs and metrics
└── webserver/          # nginx — applied to app servers only

---

## Modules

### `base`
Applied to every server — bastion and app servers alike.

| What it does | How |
|---|---|
| Installs essential packages | `vim`, `curl`, `wget`, `git`, `htop`, `net-tools` |
| Sets timezone | Symlink `/etc/localtime` driven by Hiera (`Asia/Kolkata`) |
| Disables root SSH login | `PermitRootLogin no` in `/etc/ssh/sshd_config` |
| Keeps sshd running | `service { 'sshd': ensure => running }` |

### `webserver`
Applied to app servers only (any hostname matching `/app-server/`).

| What it does | How |
|---|---|
| Installs nginx | Package resource |
| Deploys nginx config | ERB template with port and worker count from Hiera |
| Keeps nginx running | Service resource with auto-restart on config change |
| Creates app directory | `/var/www/app` owned by nginx |

### `monitoring`
Applied to every server. Ships data to AWS CloudWatch.

| What it does | How |
|---|---|
| Installs CloudWatch agent | RPM package |
| Deploys agent config | ERB template with log group and namespace from Hiera |
| Collects logs | `/var/log/messages`, `/var/log/secure`, nginx access + error logs |
| Collects metrics | CPU, memory, disk usage, network connections |
| Keeps agent running | Service resource |

---

## Hiera — how configuration data flows

Puppet looks up values in this order, stopping at the first match:

hiera/nodes/<hostname>.yaml   ← node-specific (highest priority)
hiera/common.yaml             ← defaults for all servers


**Example:** `worker_processes` for app servers
- `common.yaml` sets it to `auto`
- `nodes/appserver.yaml` overrides it to `4`
- App servers get `4`, everything else gets `auto`

This means you never touch module code to change a value per server — you only change Hiera data.

---

## Node classification (`site.pp`)

| Node pattern | Modules applied |
|---|---|
| `default` (any server) | `base`, `monitoring` |
| `/app-server/` (hostname contains "app-server") | `base`, `webserver`, `monitoring` |
| `/bastion/` (hostname contains "bastion") | `base`, `monitoring` |

---

## Key values (Hiera)

| Key | Default (`common.yaml`) | App server override |
|---|---|---|
| `base::timezone` | `Asia/Kolkata` | — |
| `webserver::app_port` | `8080` | `8080` |
| `webserver::worker_processes` | `auto` | `4` |
| `monitoring::log_group` | `dev-application-logs` | `dev-app-server-logs` |
| `monitoring::metrics_namespace` | `dev-infrastructure` | — |

---

## What Puppet enforces on every run

- Packages are installed
- Timezone symlink is correct
- Root SSH login is disabled
- sshd, nginx, and CloudWatch agent are running
- Config files match the templates exactly

If someone manually changes a config file on a server, Puppet's next run will revert it. This is called **configuration drift prevention**.

---

## What's next

- **r10k** — deploy Puppet code from Git automatically on the Puppet server
- **MCollective / Bolt** — run Puppet on demand across all servers at once
- **prod Hiera data** — separate `nodes/` yamls for production servers with different log groups and worker counts
