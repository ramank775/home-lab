# MinIO bucket + scoped IAM user for Forgejo Actions artifact storage.
# Kept private — Forgejo reaches MinIO over the in-cluster endpoint using these
# credentials; no public/anonymous access on the bucket.

resource "minio_s3_bucket" "forgejo_artifacts" {
  bucket = "forgejo-artifacts"
}

resource "random_password" "forgejo_minio_secret" {
  length  = 40
  special = false
}

resource "minio_iam_user" "forgejo_minio_user" {
  name          = "forgejo"
  secret        = random_password.forgejo_minio_secret.result
  update_secret = true
}

resource "minio_iam_policy" "forgejo_minio_policy" {
  name   = "forgejo-artifacts-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${minio_s3_bucket.forgejo_artifacts.bucket}",
        "arn:aws:s3:::${minio_s3_bucket.forgejo_artifacts.bucket}/*"
      ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "forgejo_minio_policy_attachment" {
  depends_on = [
    minio_iam_user.forgejo_minio_user,
    minio_iam_policy.forgejo_minio_policy
  ]
  user_name   = minio_iam_user.forgejo_minio_user.id
  policy_name = minio_iam_policy.forgejo_minio_policy.id
}
