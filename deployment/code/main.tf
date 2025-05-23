locals {
  admin_credentials_secret = "code-admin-creds"
}

resource "random_password" "forgejo_db_passwd" {
  length  = 16
  special = true
}


resource "postgresql_role" "forgejo_db_user" {
  name     = "forgejo"
  login    = true
  password = random_password.forgejo_db_passwd.result
}

resource "postgresql_database" "forgejo_db" {
  name                   = "forgejo"
  owner                  = "forgejo"
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.forgejo_db_user]

}

resource "random_password" "admin-password" {
  length  = 16
  special = true
}

resource "random_password" "install-security-key" {
  length  = 16
  special = true
}

resource "kubernetes_namespace" "code-ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "code-admin-creds" {
  metadata {
    name      = local.admin_credentials_secret
    namespace = var.namespace
  }
  data = {
    "username" = "adminuser"
    "password" = random_password.admin-password.result
  }
  depends_on = [
    kubernetes_namespace.code-ns
  ]
}

resource "helm_release" "forgejo" {
  depends_on = [
    postgresql_role.forgejo_db_user,
    postgresql_database.forgejo_db,
    kubernetes_secret.code-admin-creds,
    kubernetes_namespace.code-ns
  ]
  name       = "forgejo"
  namespace  = var.namespace
  chart      = "forgejo"
  repository = "oci://code.forgejo.org/forgejo-helm"
  version    = var.forgejo_version
  

  values = [
    <<EOF
replicaCount: 1

strategy:
  type: Recreate

containerSecurityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  # Add the SYS_CHROOT capability for root and rootless images if you intend to
  # run pods on nodes that use the container runtime cri-o. Otherwise, you will
  # get an error message from the SSH server that it is not possible to read from
  # the repository.
  # https://gitea.com/gitea/helm-chart/issues/161
    add:
      - SYS_CHROOT
  privileged: false
  readOnlyRootFilesystem: true
  runAsGroup: 1000
  runAsNonRoot: true
  runAsUser: 1000


global:
  storageClass: ${var.default_storage_class}

persistence:
  enabled: true
  size: 100Gi
  storageClass: ${var.default_storage_class}

ingress:
  enabled: false

service:
  http:
    type: LoadBalancer
    loadBalancerIP: "${var.forgejo_ip}"
    annotations:
      metallb.universe.tf/allow-shared-ip: forgejo
  ssh:
    type: LoadBalancer
    loadBalancerIP: "${var.forgejo_ip}"
    annotations:
      metallb.universe.tf/allow-shared-ip: forgejo
  
gitea:
  admin:
    existingSecret: ${local.admin_credentials_secret}
    passwordMode: initialOnlyRequireReset

  metrics:
    enabled: true

  cron:
    archive_cleanup:
      ENABLED: true

  session:
    PROVIDER: redis

  config:
    APP_NAME: "Code"
    
    ui:
      SHOW_USER_EMAIL: false
    meta:
      AUTHOR: "One9x"
      DESCRIPTION: "One9x Code"
      KEYWORDS: "forgejo, code, one9x"
    server:
      LANDING_PAGE: "explore"
      DOMAIN: "${var.public_host}"
      ROOT_URL: "https://${var.public_host}"
      SSH_PORT: 2222
    database:
      DB_TYPE: ${var.forgejo_database.type}
      HOST: ${var.forgejo_database.host}
      NAME: "forgejo"
      USER: "forgejo"
      PASSWD: "${random_password.forgejo_db_passwd.result}"
      SCHEMA: "public"
    security:
      INSTALL_LOCK: true
      SECRET_KEY: "${random_password.install-security-key.result}"
      PASSWORD_COMPLEXITY: "lower,upper,digit,special"
      PASSWORD_CHECK_PWN: true
    service:
      REGISTER_EMAIL_CONFIRM: true
      DISABLE_REGISTRATION: true
      DEFAULT_KEEP_EMAIL_PRIVATE: true
    mailer:
      ENABLED: true
      SMTP_ADDR: "${var.smtp.host}"
      SMTP_PORT: "${var.smtp.port}"
      FROM: "${var.email.noreply.address}"
    email:
      incoming:
        ENABLED: true
        HOST: "${var.imap.host}"
        PORT: "${var.imap.port}"
        USERNAME: "${var.email.incoming.user}"
        PASSWORD: "${var.email.incoming.passwd}"
        REPLY_TO_ADDRESS: "${var.email.incoming.address}"
redis-cluster:
  enabled: false
redis:
  enabled: true

postgresql-ha:
  enabled: false
postgresql:
  enabled: false
EOF
  ]
}
