# default node — applies to ALL servers no matter what
node default {
  include base
  include monitoring
}

# app servers — anything with "app-server" in its hostname
node /app-server/ {
  include base
  include webserver
  include monitoring
}

# bastion — only base and monitoring, no webserver
node /bastion/ {
  include base
  include monitoring
}
