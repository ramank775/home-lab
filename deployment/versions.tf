locals {
  versions = {
    charts = {
      searxng              = "1.1.0"
      n8n                  = "1.5.3"
      forgejo              = "13.0.1"
      prometheus           = "27.16.0"
      loki                 = "6.29.0"
      tempo                = "1.21.1"
      pyroscope            = "1.13.4"
      grafana              = "9.0.0"
      alloy                = "1.0.3"
      kubernetes_dashboard = "7.10.4"
    }
    images = {
      n8n                  = "1.84.3"
      postiz               = "v1.41.1"
      plausible            = "v3.0.1"
      visitor_badge        = "v1.2.0"
      visitor_badge_backup = "v1.2.0"
      dovecot              = "2.3.21.1"
      spampd               = "v2.70.0-rc.1"
      spamassassin         = "latest"
      crawl4ai             = "latest"
      static_site          = "latest"
      bind9                = "latest"
      blog_feature_post    = "v1.0.2"
      blog_oauth_provider  = "latest"
      vaultwarden          = "latest"
      vaultwarden_nginx    = "stable-alpine-slim"
      postfixadmin         = "3.3.12-apache"
      graphite_exporter    = "latest"
      sonarr               = "latest"
      radarr               = "latest"
      prowlarr             = "latest"
      spotdl               = "latest"
      jellyseerr           = "latest"
      flaresolverr         = "latest"
      redis                = "alpine"
      busybox              = "latest"
    }
  }
}
