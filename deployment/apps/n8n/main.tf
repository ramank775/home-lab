
resource "random_password" "n8n_db_passwd" {
  length  = 16
  special = true
}

resource "postgresql_role" "n8n_db_user" {
  name     = "n8n"
  login    = true
  password = random_password.n8n_db_passwd.result
}

resource "postgresql_database" "n8n_db" {
  name                   = "n8n"
  owner                  = "n8n"
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.n8n_db_user]
}

resource "minio_iam_user" "n8n_minio_user" {
  name = "n8n"
}

resource "minio_iam_policy" "n8n_minio_policy" {

  name   = "n8n-user-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::n8n-bucket/*"
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "n8n_minio_policy_attachment" {
  depends_on = [
    minio_iam_user.n8n_minio_user,
    minio_iam_policy.n8n_minio_policy
  ]
  user_name   = minio_iam_user.n8n_minio_user.id
  policy_name = minio_iam_policy.n8n_minio_policy.id
}

resource "minio_s3_bucket" "n8n_bucket" {
  bucket = "n8n-bucket"
}

resource "minio_s3_bucket_policy" "n8n_bucket_policy" {
  bucket = minio_s3_bucket.n8n_bucket.bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam:::user/n8n-user"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::n8n-bucket",
        "arn:aws:s3:::n8n-bucket/*"
      ]
    }
  ]
}
EOF
}

resource "helm_release" "n8n" {

  depends_on = [
    minio_iam_user.n8n_minio_user,
    minio_iam_policy.n8n_minio_policy,
    minio_iam_user_policy_attachment.n8n_minio_policy_attachment,
    minio_s3_bucket.n8n_bucket,
    minio_s3_bucket_policy.n8n_bucket_policy,
    postgresql_database.n8n_db
  ]

  name       = "n8n"
  namespace  = var.namespace
  chart      = "n8n"
  repository = "https://community-charts.github.io/helm-charts"
  version    = var.helm_version

  create_namespace = true

  values = [
    <<EOF

image:
  tag: ${var.image_tag}

license:
  enabled: true
  activationKey: "${var.n8n_license_key}"

db:
  type: postgresdb
# This required enterprise license key
# binaryData:
#   availableModes:
#     - s3
#   mode: "s3"
#   s3:
#     host: "${var.minio.server}"
#     bucketName: "n8n-bucket"
#     bucketRegion: "us-east-1"
#     accessKey: "${minio_iam_user.n8n_minio_user.id}"
#     accessSecret: "${minio_iam_user.n8n_minio_user.secret}"

externalPostgresql:
  host: ${var.database.host}
  port: ${var.database.port}
  username: "n8n"
  password: ${random_password.n8n_db_passwd.result}
  database: "n8n"

redis:
  enabled: true

worker:
  mode: queue

webhook:
  mode: queue
  url: "https://webhook.${var.domain}"

ingress:
  enabled: true
  hosts:
    - host: ${var.domain}
      paths:
        - path: /
          pathType: Prefix
EOF
  ]
}
